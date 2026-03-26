import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import '../config/api_config.dart';

/// Analysis API service
class AnalysisApi {
  final ApiService _apiService = ApiService();

  /// Create new analysis with PlatformFiles (works on web and mobile)
  Future<Map<String, dynamic>> createAnalysisWithFiles({
    required String patientId,
    String? typedText,
    List<PlatformFile>? audioFiles,
    List<PlatformFile>? pdfFiles,
    List<XFile>? imageFiles,
    Function(int, int)? onProgress,
  }) async {
    // Create FormData
    final formData = FormData();

    // Add patient ID
    formData.fields.add(MapEntry('patient_id', patientId));

    // Add typed text
    if (typedText != null && typedText.isNotEmpty) {
      formData.fields.add(MapEntry('typed_text', typedText));
    }

    // Add audio files
    if (audioFiles != null) {
      for (final file in audioFiles) {
        if (kIsWeb) {
          // For web: use bytes
          if (file.bytes != null) {
            formData.files.add(MapEntry(
              'audio_files',
              MultipartFile.fromBytes(
                file.bytes!,
                filename: file.name,
              ),
            ));
          }
        } else {
          // For mobile: use file path
          if (file.path != null) {
            formData.files.add(MapEntry(
              'audio_files',
              await MultipartFile.fromFile(
                file.path!,
                filename: file.name,
              ),
            ));
          }
        }
      }
    }

    // Add PDF files
    if (pdfFiles != null) {
      for (final file in pdfFiles) {
        if (kIsWeb) {
          // For web: use bytes
          if (file.bytes != null) {
            formData.files.add(MapEntry(
              'pdf_files',
              MultipartFile.fromBytes(
                file.bytes!,
                filename: file.name,
              ),
            ));
          }
        } else {
          // For mobile: use file path
          if (file.path != null) {
            formData.files.add(MapEntry(
              'pdf_files',
              await MultipartFile.fromFile(
                file.path!,
                filename: file.name,
              ),
            ));
          }
        }
      }
    }

    // Add image files
    if (imageFiles != null) {
      for (final xFile in imageFiles) {
        if (kIsWeb) {
          // For web: read bytes from XFile
          final bytes = await xFile.readAsBytes();
          formData.files.add(MapEntry(
            'image_files',
            MultipartFile.fromBytes(
              bytes,
              filename: xFile.name,
            ),
          ));
        } else {
          // For mobile: use file path
          formData.files.add(MapEntry(
            'image_files',
            await MultipartFile.fromFile(
              xFile.path,
              filename: xFile.name,
            ),
          ));
        }
      }
    }

    final response = await _apiService.postFormData(
      ApiConfig.analysisCreate,
      formData,
      onSendProgress: onProgress,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Create new analysis (legacy method for File objects)
  Future<Map<String, dynamic>> createAnalysis({
    required String patientId,
    String? typedText,
    List<File>? audioFiles,
    List<File>? pdfFiles,
    List<File>? imageFiles,
    Function(int, int)? onProgress,
  }) async {
    // Create FormData
    final formData = FormData();

    // Add patient ID
    formData.fields.add(MapEntry('patient_id', patientId));

    // Add typed text
    if (typedText != null && typedText.isNotEmpty) {
      formData.fields.add(MapEntry('typed_text', typedText));
    }

    // Add audio files
    if (audioFiles != null) {
      for (final file in audioFiles) {
        formData.files.add(MapEntry(
          'audio_files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }
    }

    // Add PDF files
    if (pdfFiles != null) {
      for (final file in pdfFiles) {
        formData.files.add(MapEntry(
          'pdf_files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }
    }

    // Add image files
    if (imageFiles != null) {
      for (final file in imageFiles) {
        formData.files.add(MapEntry(
          'image_files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }
    }

    final response = await _apiService.postFormData(
      ApiConfig.analysisCreate,
      formData,
      onSendProgress: onProgress,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get analysis by ID
  Future<Map<String, dynamic>> getAnalysisById(String analysisId) async {
    final response = await _apiService.get(
      ApiConfig.analysisById(analysisId),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiService.get(
      ApiConfig.analysisDashboardStats,
    );

    return response.data as Map<String, dynamic>;
  }

  /// Ask follow-up question
  Future<Map<String, dynamic>> askFollowupQuestion({
    required String analysisId,
    required String question,
  }) async {
    final response = await _apiService.post(
      ApiConfig.analysisFollowup(analysisId),
      data: {'question': question},
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get follow-up history
  Future<Map<String, dynamic>> getFollowupHistory(String analysisId) async {
    final response = await _apiService.get(
      ApiConfig.analysisFollowup(analysisId),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Get patient analyses
  Future<Map<String, dynamic>> getPatientAnalyses(String patientId) async {
    final response = await _apiService.get(
      ApiConfig.patientAnalyses(patientId),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Export analysis to PDF
  Future<void> exportToPdf({
    required String analysisId,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    await _apiService.downloadFile(
      ApiConfig.exportPdf(analysisId),
      savePath,
      onReceiveProgress: onProgress,
    );
  }
}
