import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import 'firebase_service.dart';
import 'network_service.dart';

/// API service using DIO for HTTP requests
/// Handles all communication with the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FirebaseService _firebaseService = FirebaseService();
  final Logger _logger = Logger();

  ApiService._internal() {
    // Note: sendTimeout is not supported on web with request bodies
    // Only set it for non-web platforms to avoid warnings
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: kIsWeb ? null : ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request interceptor - Add Firebase UID to headers and cache-busting for web
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get current Firebase UID
          final firebaseUid = await _firebaseService.getCurrentUserUid();

          if (firebaseUid != null) {
            options.headers['Authorization'] = 'Bearer $firebaseUid';
          }

          // CRITICAL: Add cache-busting headers for web to prevent
          // service worker from caching failed responses
          if (kIsWeb) {
            options.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
            options.headers['Pragma'] = 'no-cache';
            options.headers['Expires'] = '0';
          }

          _logger.d('REQUEST: ${options.method} ${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Data: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('Error message: ${error.message}');
          if (error.response?.data != null) {
            _logger.e('Error data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST with FormData (for file uploads)
  Future<Response> postFormData(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Handle DioException and throw user-friendly message
  ///
  /// IMPORTANT: On Flutter Web, DioExceptionType.connectionError does NOT
  /// reliably indicate "no internet". It can mean:
  /// - Mixed content blocked (HTTP from HTTPS page)
  /// - CORS policy blocked the request
  /// - SSL/TLS certificate error
  /// - Server is down
  /// - Actual network offline
  ///
  /// We use NetworkService.isLikelyOffline() to provide accurate messages.
  void _handleError(DioException error) {
    String message = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorData = error.response?.data;

        if (statusCode == 401) {
          message = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          message = errorData is Map ? (errorData['detail'] ?? 'Resource not found.') : 'Resource not found.';
        } else if (statusCode == 409) {
          message = errorData is Map ? (errorData['detail'] ?? 'Conflict error.') : 'Conflict error.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        } else if (errorData is Map && errorData['detail'] != null) {
          message = errorData['detail'];
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.badCertificate:
        // On web, this can also indicate mixed content issues
        if (kIsWeb) {
          message = 'Unable to establish secure connection. Please contact support.';
        } else {
          message = 'Certificate verification failed.';
        }
        break;
      case DioExceptionType.connectionError:
        // CRITICAL: Don't blindly say "No internet" on web
        // The request may have been blocked for other reasons
        if (NetworkService.isLikelyOffline(error)) {
          message = 'No internet connection. Please check your network.';
        } else if (kIsWeb) {
          // On web, connectionError often means the request was blocked
          // Give a more accurate message
          message = 'Unable to connect to server. Please try again.';
          _logger.w('Web connectionError - likely CORS/mixed content/SSL issue');
          _logger.w('Error details: ${error.error}');
        } else {
          message = 'Connection failed. Please check your network.';
        }
        break;
      case DioExceptionType.unknown:
        // On web, unknown errors often wrap browser-specific issues
        if (kIsWeb) {
          final errorStr = error.error?.toString().toLowerCase() ?? '';
          if (errorStr.contains('clientexception') ||
              errorStr.contains('failed to fetch') ||
              errorStr.contains('network error')) {
            message = 'Unable to connect to server. Please try again.';
          } else {
            message = 'An unexpected error occurred. Please try again.';
          }
        } else {
          message = 'An unexpected error occurred. Please try again.';
        }
        break;
    }

    _logger.e('API Error: $message');
    _logger.e('Original error type: ${error.type}');
    _logger.e('Original error: ${error.error}');
    throw Exception(message);
  }
}
