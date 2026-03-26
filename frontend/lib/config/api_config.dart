/// API configuration for Clinical AI Dashboard
class ApiConfig {
  ApiConfig._();

  /// Base URL for backend API
  /// IMPORTANT: Must use HTTPS in production to avoid mixed content blocking
  /// on Flutter Web. Browsers block HTTP requests from HTTPS pages.
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// API endpoints
  static const String apiPrefix = '/api';

  // ==================== AUTH ENDPOINTS ====================
  static const String authVerify = '$apiPrefix/auth/verify';
  static const String authMe = '$apiPrefix/auth/me';

  // ==================== PATIENT ENDPOINTS ====================
  static const String patients = '$apiPrefix/patients';
  static String patientById(String id) => '$patients/$id';
  static String patientAnalyses(String id) => '$patients/$id/analyses';

  // ==================== ANALYSIS ENDPOINTS ====================
  static const String analysisCreate = '$apiPrefix/analysis/create';
  static String analysisById(String id) => '$apiPrefix/analysis/$id';
  static const String analysisDashboardStats =
      '$apiPrefix/analysis/dashboard/stats';
  static String analysisFollowup(String id) =>
      '$apiPrefix/analysis/$id/followup';

  // ==================== EXPORT ENDPOINTS ====================
  static String exportPdf(String id) => '$apiPrefix/export/pdf/$id';

  // ==================== TIMEOUT SETTINGS ====================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // ==================== PAGINATION DEFAULTS ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
