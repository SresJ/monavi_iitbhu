import 'api_service.dart';
import '../config/api_config.dart';

/// Patient API service
class PatientApi {
  final ApiService _apiService = ApiService();

  /// Get list of patients with pagination and search
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiService.get(
      ApiConfig.patients,
      queryParameters: queryParams,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get patient by ID
  Future<Map<String, dynamic>> getPatientById(String patientId) async {
    final response = await _apiService.get(
      ApiConfig.patientById(patientId),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Create new patient
  Future<Map<String, dynamic>> createPatient({
    required String fullName,
    int? age,
    String? sex,
    String? mrn,
    String? email,
    String? phone,
  }) async {
    final data = {
      'full_name': fullName,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (mrn != null) 'mrn': mrn,
      if (email != null || phone != null)
        'contact': {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
    };

    final response = await _apiService.post(
      ApiConfig.patients,
      data: data,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Update patient
  Future<Map<String, dynamic>> updatePatient({
    required String patientId,
    String? fullName,
    int? age,
    String? sex,
    String? mrn,
    String? email,
    String? phone,
  }) async {
    final data = <String, dynamic>{};

    if (fullName != null) data['full_name'] = fullName;
    if (age != null) data['age'] = age;
    if (sex != null) data['sex'] = sex;
    if (mrn != null) data['mrn'] = mrn;

    if (email != null || phone != null) {
      data['contact'] = {};
      if (email != null) data['contact']['email'] = email;
      if (phone != null) data['contact']['phone'] = phone;
    }

    final response = await _apiService.put(
      ApiConfig.patientById(patientId),
      data: data,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Delete patient
  Future<void> deletePatient(String patientId) async {
    await _apiService.delete(
      ApiConfig.patientById(patientId),
    );
  }

  /// Get patient analyses
  Future<Map<String, dynamic>> getPatientAnalyses(String patientId) async {
    final response = await _apiService.get(
      ApiConfig.patientAnalyses(patientId),
    );

    return response.data as Map<String, dynamic>;
  }
}
