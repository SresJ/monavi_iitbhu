import 'api_service.dart';
import '../config/api_config.dart';

/// Authentication API service
class AuthApi {
  final ApiService _apiService = ApiService();

  /// Verify doctor with backend
  /// Called after Firebase authentication to create/update doctor record
  Future<Map<String, dynamic>> verifyDoctor({
    required String email,
    required String fullName,
    String? specialty,
  }) async {
    final response = await _apiService.post(
      ApiConfig.authVerify,
      data: {
        'email': email,
        'full_name': fullName,
        if (specialty != null) 'specialty': specialty,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get current doctor profile
  Future<Map<String, dynamic>> getCurrentDoctor() async {
    final response = await _apiService.get(ApiConfig.authMe);
    return response.data as Map<String, dynamic>;
  }
}
