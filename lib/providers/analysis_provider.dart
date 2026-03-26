import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/analysis.dart';
import '../models/dashboard_stats.dart';
import '../services/analysis_api.dart';

/// Analysis management state provider
class AnalysisProvider with ChangeNotifier {
  final AnalysisApi _analysisApi = AnalysisApi();

  DashboardStats? _dashboardStats;
  Analysis? _currentAnalysis;
  List<Analysis> _patientAnalyses = [];
  List<Analysis> _recentAnalyses = [];
  List<FollowupQA> _followupHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _uploadProgress = 0;

  DashboardStats? get dashboardStats => _dashboardStats;
  Analysis? get currentAnalysis => _currentAnalysis;
  List<Analysis> get patientAnalyses => _patientAnalyses;
  List<Analysis> get recentAnalyses => _recentAnalyses;
  List<FollowupQA> get followupHistory => _followupHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get uploadProgress => _uploadProgress;

  /// Fetch dashboard statistics
  Future<void> fetchDashboardStats() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _analysisApi.getDashboardStats();
      _dashboardStats = DashboardStats.fromJson(response);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Fetch recent analyses (for dashboard insights)
  /// This method aggregates analyses from recent patients
  Future<void> fetchRecentAnalyses() async {
    try {
      // For now, use patient analyses as a proxy for recent analyses
      // In production, backend should provide a dedicated endpoint
      _recentAnalyses = List.from(_patientAnalyses);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Create new analysis with PlatformFiles (works on web and mobile)
  Future<String?> createAnalysisWithFiles({
    required String patientId,
    String? typedText,
    List<PlatformFile>? audioFiles,
    List<PlatformFile>? pdfFiles,
    List<XFile>? imageFiles,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      _uploadProgress = 0;

      final response = await _analysisApi.createAnalysisWithFiles(
        patientId: patientId,
        typedText: typedText,
        audioFiles: audioFiles,
        pdfFiles: pdfFiles,
        imageFiles: imageFiles,
        onProgress: (sent, total) {
          _uploadProgress = ((sent / total) * 100).round();
          notifyListeners();
        },
      );

      _currentAnalysis = Analysis.fromJson(response);
      _uploadProgress = 100;

      _setLoading(false);
      notifyListeners();
      return _currentAnalysis?.analysisId;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      _uploadProgress = 0;
      return null;
    }
  }

  /// Create new analysis (returns analysis ID) - Legacy method for File objects
  Future<String?> createAnalysis({
    required String patientId,
    String? typedText,
    List<File>? audioFiles,
    List<File>? pdfFiles,
    List<File>? imageFiles,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      _uploadProgress = 0;

      final response = await _analysisApi.createAnalysis(
        patientId: patientId,
        typedText: typedText,
        audioFiles: audioFiles,
        pdfFiles: pdfFiles,
        imageFiles: imageFiles,
        onProgress: (sent, total) {
          _uploadProgress = ((sent / total) * 100).round();
          notifyListeners();
        },
      );

      _currentAnalysis = Analysis.fromJson(response);
      _uploadProgress = 100;

      _setLoading(false);
      notifyListeners();
      return _currentAnalysis?.analysisId;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      _uploadProgress = 0;
      return null;
    }
  }

  /// Get analysis by ID
  Future<Analysis?> getAnalysisById(String analysisId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _analysisApi.getAnalysisById(analysisId);
      _currentAnalysis = Analysis.fromJson(response);

      _setLoading(false);
      notifyListeners();
      return _currentAnalysis;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Ask follow-up question (does NOT use shared loading state)
  Future<FollowupQA?> askFollowupQuestion({
    required String analysisId,
    required String question,
  }) async {
    try {
      _clearError();

      final response = await _analysisApi.askFollowupQuestion(
        analysisId: analysisId,
        question: question,
      );

      final qa = FollowupQA.fromJson(response);

      // Prevent duplicates by checking if already exists
      final exists = _followupHistory.any((existing) =>
        existing.question == qa.question &&
        existing.askedAt.difference(qa.askedAt).inSeconds.abs() < 5
      );

      if (!exists) {
        _followupHistory.add(qa);
      }

      notifyListeners();
      return qa;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Get follow-up history (returns the list, does NOT use shared loading)
  Future<List<FollowupQA>> getFollowupHistory(String analysisId) async {
    try {
      _clearError();

      final response = await _analysisApi.getFollowupHistory(analysisId);
      _followupHistory = (response['qa_pairs'] as List?)
              ?.map((qa) => FollowupQA.fromJson(qa))
              .toList() ??
          [];

      notifyListeners();
      return _followupHistory;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Clear followup history (call when switching analyses)
  void clearFollowupHistory() {
    _followupHistory = [];
    notifyListeners();
  }

  /// Fetch follow-up history (void method for backwards compatibility)
  Future<void> fetchFollowupHistory(String analysisId) async {
    await getFollowupHistory(analysisId);
  }

  /// Export analysis to PDF
  Future<bool> exportToPdf({
    required String analysisId,
    required String savePath,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _analysisApi.exportToPdf(
        analysisId: analysisId,
        savePath: savePath,
        onProgress: (received, total) {
          _uploadProgress = ((received / total) * 100).round();
          notifyListeners();
        },
      );

      _setLoading(false);
      _uploadProgress = 0;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      _uploadProgress = 0;
      return false;
    }
  }

  /// Load patient analyses
  Future<void> loadPatientAnalyses(String patientId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _analysisApi.getPatientAnalyses(patientId);
      _patientAnalyses = (response['analyses'] as List?)
              ?.map((a) => Analysis.fromJson(a))
              .toList() ??
          [];

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    _followupHistory = [];
    notifyListeners();
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
