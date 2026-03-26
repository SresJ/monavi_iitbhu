import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// Network connectivity result with detailed status
enum NetworkStatus {
  /// Device is online and API is reachable
  online,

  /// Device appears offline (no network)
  offline,

  /// Device has network but API is unreachable (server down, CORS, blocked)
  apiUnreachable,

  /// Unknown state (check in progress or failed)
  unknown,
}

/// Production-safe network connectivity service
/// Works correctly on Web, Android, and iOS
///
/// IMPORTANT: Does NOT use connectivity_plus because:
/// - On web, it only checks navigator.onLine which is unreliable
/// - It doesn't verify actual API reachability
/// - It can't detect mixed content blocking or CORS issues
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal();

  /// Dedicated Dio instance for connectivity checks
  /// Separate from main ApiService to avoid interceptor side effects
  late final Dio _connectivityDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    // No base URL - we'll use full URLs for flexibility
  ));

  /// Check if the device has network connectivity AND can reach the API
  ///
  /// This is the production-safe way to check connectivity on Flutter Web.
  /// It makes an actual HTTP request instead of relying on browser APIs.
  ///
  /// Returns [NetworkStatus.online] if API is reachable
  /// Returns [NetworkStatus.offline] if device has no network
  /// Returns [NetworkStatus.apiUnreachable] if device has network but API is blocked/down
  Future<NetworkStatus> checkConnectivity() async {
    try {
      // Use cache-busting query parameter to bypass service worker cache
      // This prevents false positives from cached responses
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final healthUrl = '${ApiConfig.baseUrl}/health?_cb=$cacheBuster';

      final response = await _connectivityDio.head(
        healthUrl,
        options: Options(
          // Prevent caching on web
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
          // Don't follow redirects for health check
          followRedirects: false,
          validateStatus: (status) {
            // Accept any response as "reachable" - even 4xx/5xx means API is up
            return status != null && status < 600;
          },
        ),
      );

      // Any response means we're online and API is reachable
      return NetworkStatus.online;
    } on DioException catch (e) {
      return _classifyDioException(e);
    } catch (e) {
      // Catch-all for unexpected errors
      if (kDebugMode) {
        developer.log(
          'Unexpected error during connectivity check: $e',
          name: 'NetworkService',
        );
      }
      return NetworkStatus.unknown;
    }
  }

  /// Classify a DioException into a NetworkStatus
  /// Handles web-specific error conditions correctly
  NetworkStatus _classifyDioException(DioException e) {
    if (kDebugMode) {
      developer.log(
        'DioException type=${e.type}, message=${e.message}',
        name: 'NetworkService',
      );
      developer.log(
        'Error=${e.error?.runtimeType}: ${e.error}',
        name: 'NetworkService',
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Timeouts usually mean network is slow or API is overloaded
        // but device has connectivity
        return NetworkStatus.apiUnreachable;

      case DioExceptionType.connectionError:
        // On web, this can mean:
        // 1. Actual network offline
        // 2. Mixed content blocked (HTTP from HTTPS)
        // 3. CORS blocked
        // 4. SSL/TLS error
        //
        // We need to check the underlying error to differentiate
        return _classifyConnectionError(e);

      case DioExceptionType.badResponse:
        // Got a response, so we're online (even if it's an error response)
        return NetworkStatus.online;

      case DioExceptionType.badCertificate:
        // SSL error - device has network but can't establish secure connection
        return NetworkStatus.apiUnreachable;

      case DioExceptionType.cancel:
        return NetworkStatus.unknown;

      case DioExceptionType.unknown:
        return _classifyUnknownError(e);
    }
  }

  /// Classify connection errors - especially important for web
  NetworkStatus _classifyConnectionError(DioException e) {
    final error = e.error;
    final message = e.message?.toLowerCase() ?? '';

    // On web, check for specific error patterns
    if (kIsWeb) {
      // XMLHttpRequest errors on web often indicate CORS or mixed content
      if (message.contains('xmlhttprequest') ||
          message.contains('network error') ||
          message.contains('failed to fetch')) {
        // Could be CORS, mixed content, or actual offline
        // Try to differentiate by checking navigator.onLine (hint only)
        return NetworkStatus.apiUnreachable;
      }
    }

    // Check error type string for common patterns
    final errorString = error?.toString().toLowerCase() ?? '';

    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('host lookup') ||
        errorString.contains('no address associated')) {
      // These indicate network-level issues
      return NetworkStatus.offline;
    }

    if (errorString.contains('handshake') ||
        errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('tls')) {
      // SSL/TLS issues - network exists but connection failed
      return NetworkStatus.apiUnreachable;
    }

    // Default: assume API unreachable rather than offline
    // This is safer because it doesn't blame the user's network
    return NetworkStatus.apiUnreachable;
  }

  /// Classify unknown DioException errors
  NetworkStatus _classifyUnknownError(DioException e) {
    final errorString = e.error?.toString().toLowerCase() ?? '';
    final message = e.message?.toLowerCase() ?? '';

    // Check for web-specific errors
    if (kIsWeb) {
      if (errorString.contains('clientexception') ||
          message.contains('clientexception')) {
        // http package's ClientException wrapped by DIO
        return NetworkStatus.apiUnreachable;
      }
    }

    // Check for socket/network errors
    if (errorString.contains('socket') ||
        errorString.contains('connection')) {
      return NetworkStatus.offline;
    }

    return NetworkStatus.unknown;
  }

  /// Get a user-friendly message for a network status
  static String getStatusMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online:
        return 'Connected';
      case NetworkStatus.offline:
        return 'No internet connection. Please check your network.';
      case NetworkStatus.apiUnreachable:
        return 'Unable to reach server. Please try again later.';
      case NetworkStatus.unknown:
        return 'Connection status unknown. Please try again.';
    }
  }

  /// Check if a DioException represents an actual offline condition
  /// vs a server/API issue
  ///
  /// Use this in your API service error handling to provide accurate messages
  static bool isLikelyOffline(DioException e) {
    // On web, we can't reliably determine offline vs blocked
    // Be conservative and return false (don't blame user's network)
    if (kIsWeb) {
      final error = e.error?.toString().toLowerCase() ?? '';
      // Only return true for very specific offline indicators
      return error.contains('no internet') ||
          error.contains('network unreachable');
    }

    // On native platforms, connectionError is more reliable
    if (e.type == DioExceptionType.connectionError) {
      final error = e.error?.toString().toLowerCase() ?? '';
      return error.contains('socketexception') ||
          error.contains('host lookup') ||
          error.contains('no address');
    }

    return false;
  }
}
