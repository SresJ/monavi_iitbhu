import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/patient_api.dart';

/// Patient management state provider
class PatientProvider with ChangeNotifier {
  final PatientApi _patientApi = PatientApi();

  List<Patient> _patients = [];
  int _total = 0;
  int _currentPage = 1;
  String? _searchQuery;
  bool _isLoading = false;
  String? _errorMessage;

  // Cache management
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Dummy patients with Indian names for demo purposes
  static final List<Patient> _dummyPatients = [
    Patient(
      patientId: 'dummy-1',
      fullName: 'Priya Sharma',
      age: 34,
      sex: 'female',
      mrn: 'MRN-2024-001',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Patient(
      patientId: 'dummy-2',
      fullName: 'Rajesh Kumar',
      age: 52,
      sex: 'male',
      mrn: 'MRN-2024-002',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Patient(
      patientId: 'dummy-3',
      fullName: 'Ananya Patel',
      age: 28,
      sex: 'female',
      mrn: 'MRN-2024-003',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Patient(
      patientId: 'dummy-4',
      fullName: 'Vikram Singh',
      age: 45,
      sex: 'male',
      mrn: 'MRN-2024-004',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<Patient> get patients {
    // Merge real patients with dummy patients, filtering by search if active
    final allPatients = [..._patients, ..._dummyPatients];
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      return allPatients.where((p) => p.fullName.toLowerCase().contains(query)).toList();
    }
    return allPatients;
  }
  int get total => _total + _dummyPatients.length;
  int get currentPage => _currentPage;
  String? get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _patients.length < _total; // Only real patients paginate

  /// Fetch patients with pagination and search
  Future<void> fetchPatients({
    int page = 1,
    int limit = 20,
    String? search,
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh &&
        _patients.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        search == _searchQuery &&
        page == _currentPage) {
      return; // Use cached data
    }

    try {
      _setLoading(true);
      _clearError();

      final response = await _patientApi.getPatients(
        page: page,
        limit: limit,
        search: search,
      );

      if (page == 1) {
        _patients = (response['patients'] as List)
            .map((p) => Patient.fromJson(p))
            .toList();
      } else {
        _patients.addAll((response['patients'] as List)
            .map((p) => Patient.fromJson(p))
            .toList());
      }

      _total = response['total'] as int;
      _currentPage = page;
      _searchQuery = search;
      _lastFetchTime = DateTime.now();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Get patient by ID
  Future<Patient?> getPatientById(String patientId) async {
    // Check if it's a dummy patient first
    final dummyPatient = _dummyPatients.where((p) => p.patientId == patientId).firstOrNull;
    if (dummyPatient != null) {
      return dummyPatient;
    }

    try {
      _setLoading(true);
      _clearError();

      final response = await _patientApi.getPatientById(patientId);
      final patient = Patient.fromJson(response);

      _setLoading(false);
      return patient;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Create new patient
  Future<Patient?> createPatient({
    required String fullName,
    int? age,
    String? sex,
    String? mrn,
    String? email,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _patientApi.createPatient(
        fullName: fullName,
        age: age,
        sex: sex,
        mrn: mrn,
        email: email,
        phone: phone,
      );

      final patient = Patient.fromJson(response);

      // Add to local list
      _patients.insert(0, patient);
      _total++;

      _setLoading(false);
      notifyListeners();
      return patient;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Update patient
  Future<Patient?> updatePatient({
    required String patientId,
    String? fullName,
    int? age,
    String? sex,
    String? mrn,
    String? email,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _patientApi.updatePatient(
        patientId: patientId,
        fullName: fullName,
        age: age,
        sex: sex,
        mrn: mrn,
        email: email,
        phone: phone,
      );

      final updatedPatient = Patient.fromJson(response);

      // Update in local list
      final index = _patients.indexWhere((p) => p.patientId == patientId);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }

      _setLoading(false);
      notifyListeners();
      return updatedPatient;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String patientId) async {
    try {
      _setLoading(true);
      _clearError();

      await _patientApi.deletePatient(patientId);

      // Remove from local list
      _patients.removeWhere((p) => p.patientId == patientId);
      _total--;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Search patients
  Future<void> searchPatients(String query) async {
    await fetchPatients(page: 1, search: query, forceRefresh: true);
  }

  /// Load more patients (pagination)
  Future<void> loadMore() async {
    if (!_isLoading && hasMore) {
      await fetchPatients(
        page: _currentPage + 1,
        search: _searchQuery,
      );
    }
  }

  /// Refresh patients
  Future<void> refresh() async {
    await fetchPatients(page: 1, search: _searchQuery, forceRefresh: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
