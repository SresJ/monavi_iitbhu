import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Firebase service for authentication
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  static const String _uidKey = 'firebase_uid';
  static const String _emailKey = 'firebase_email';

  FirebaseService._internal();

  /// Sign up with email and password
  Future<String> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Signing up user: $email');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await _storeCredentials(uid, email);

      _logger.i('User signed up successfully: $uid');
      return uid;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase signup error: ${e.code} - ${e.message}');
      throw _handleFirebaseError(e);
    }
  }

  /// Sign in with email and password
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Signing in user: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await _storeCredentials(uid, email);

      _logger.i('User signed in successfully: $uid');
      return uid;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase signin error: ${e.code} - ${e.message}');
      throw _handleFirebaseError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.d('Signing out user');

      await _firebaseAuth.signOut();
      await _clearCredentials();

      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Get current user UID
  Future<String?> getCurrentUserUid() async {
    // First try to get from current Firebase user
    final user = getCurrentUser();
    if (user != null) {
      return user.uid;
    }

    // Fall back to secure storage
    return await _secureStorage.read(key: _uidKey);
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    final user = getCurrentUser();
    if (user != null) {
      return true;
    }

    // Check secure storage
    final uid = await _secureStorage.read(key: _uidKey);
    return uid != null;
  }

  /// Store credentials in secure storage
  Future<void> _storeCredentials(String uid, String email) async {
    await _secureStorage.write(key: _uidKey, value: uid);
    await _secureStorage.write(key: _emailKey, value: email);
  }

  /// Clear stored credentials
  Future<void> _clearCredentials() async {
    await _secureStorage.delete(key: _uidKey);
    await _secureStorage.delete(key: _emailKey);
  }

  /// Get stored email
  Future<String?> getStoredEmail() async {
    return await _secureStorage.read(key: _emailKey);
  }

  /// Handle Firebase authentication errors
  Exception _handleFirebaseError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered. Please sign in instead.';
        break;
      case 'invalid-email':
        message = 'Invalid email address.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password sign-in is not enabled.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please use at least 6 characters.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'network-request-failed':
        // On web, network errors can also be caused by CORS/mixed content
        if (kIsWeb) {
          message = 'Unable to connect to authentication server. Please try again.';
        } else {
          message = 'Network error. Please check your internet connection.';
        }
        break;
      default:
        message = e.message ?? 'An error occurred during authentication.';
    }

    return Exception(message);
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
