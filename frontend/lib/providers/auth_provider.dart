import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../services/firebase_service.dart';
import '../services/auth_api.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthApi _authApi = AuthApi();

  Doctor? _currentDoctor;
  bool _isLoading = false;
  String? _errorMessage;

  Doctor? get currentDoctor => _currentDoctor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentDoctor != null;

  /// Sign up new doctor
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? specialty,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // 1. Create Firebase account
      await _firebaseService.signUpWithEmail(
        email: email,
        password: password,
      );

      // 2. Verify with backend and create doctor record
      final doctorData = await _authApi.verifyDoctor(
        email: email,
        fullName: fullName,
        specialty: specialty,
      );

      _currentDoctor = Doctor.fromJson(doctorData);
      _setLoading(false);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in existing doctor
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // 1. Sign in with Firebase
      await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      // 2. Get doctor profile from backend
      final doctorData = await _authApi.getCurrentDoctor();
      _currentDoctor = Doctor.fromJson(doctorData);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Check if user is already authenticated
  /// Called on app startup
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);

      final isSignedIn = await _firebaseService.isSignedIn();

      if (isSignedIn) {
        // Get doctor profile from backend
        final doctorData = await _authApi.getCurrentDoctor();
        _currentDoctor = Doctor.fromJson(doctorData);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      // Don't set error - just means user is not authenticated
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _firebaseService.signOut();
      _currentDoctor = null;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
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
