/// Evidence from medical literature
class Evidence {
  final String evidenceText;
  final String sourceUrl;
  final String sourceName;

  Evidence({
    required this.evidenceText,
    required this.sourceUrl,
    required this.sourceName,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      evidenceText: json['evidence_text'] as String? ?? '',
      sourceUrl: json['source_url'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evidence_text': evidenceText,
      'source_url': sourceUrl,
      'source_name': sourceName,
    };
  }
}

/// Diagnosis with confidence and evidence
class Diagnosis {
  final String diagnosisName;
  final double confidence;  // 0.0-1.0
  final String confidenceLevel;  // high/medium/low
  final List<String> triggeringSymptoms;
  final List<String> confidenceRationale;
  final List<Evidence> evidence;

  Diagnosis({
    required this.diagnosisName,
    required this.confidence,
    required this.confidenceLevel,
    required this.triggeringSymptoms,
    required this.confidenceRationale,
    required this.evidence,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      diagnosisName: json['diagnosis_name'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: json['confidence_level'] as String? ?? 'low',
      triggeringSymptoms: (json['triggering_symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      confidenceRationale: (json['confidence_rationale'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => Evidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis_name': diagnosisName,
      'confidence': confidence,
      'confidence_level': confidenceLevel,
      'triggering_symptoms': triggeringSymptoms,
      'confidence_rationale': confidenceRationale,
      'evidence': evidence.map((e) => e.toJson()).toList(),
    };
  }

  /// Get confidence percentage (0-100)
  int get confidencePercentage => (confidence * 100).round();

  /// Get confidence level display text
  String get confidenceLevelDisplay => confidenceLevel.toUpperCase();
}

/// Clinical summary
class Summary {
  final int? age;
  final String? sex;
  final String? chiefComplaint;
  final List<String> associatedSymptoms;
  final String? duration;
  final String formattedSummary;

  Summary({
    this.age,
    this.sex,
    this.chiefComplaint,
    required this.associatedSymptoms,
    this.duration,
    required this.formattedSummary,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      age: json['age'] as int?,
      sex: json['sex'] as String?,
      chiefComplaint: json['chief_complaint'] as String?,
      associatedSymptoms: (json['associated_symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      duration: json['duration'] as String?,
      formattedSummary: json['formatted_summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      'associated_symptoms': associatedSymptoms,
      if (duration != null) 'duration': duration,
      'formatted_summary': formattedSummary,
    };
  }
}

/// Diagnostic test suggestion
class DiagnosticTest {
  final String testName;
  final String rationale;

  DiagnosticTest({
    required this.testName,
    required this.rationale,
  });

  factory DiagnosticTest.fromJson(Map<String, dynamic> json) {
    return DiagnosticTest(
      testName: json['test_name'] as String? ?? '',
      rationale: json['rationale'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_name': testName,
      'rationale': rationale,
    };
  }
}

/// Complete analysis result
class Analysis {
  final String analysisId;
  final String patientId;
  final Summary summary;
  final List<Diagnosis> diagnoses;
  final List<DiagnosticTest> diagnosticTests;
  final List<String> missingInfo;
  final DateTime createdAt;

  Analysis({
    required this.analysisId,
    required this.patientId,
    required this.summary,
    required this.diagnoses,
    required this.diagnosticTests,
    required this.missingInfo,
    required this.createdAt,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      analysisId: json['analysis_id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      diagnoses: (json['diagnoses'] as List<dynamic>?)
              ?.map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      diagnosticTests: (json['diagnostic_tests'] as List<dynamic>?)
              ?.map((e) => DiagnosticTest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      missingInfo: (json['missing_info'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'patient_id': patientId,
      'summary': summary.toJson(),
      'diagnoses': diagnoses.map((e) => e.toJson()).toList(),
      'diagnostic_tests': diagnosticTests.map((e) => e.toJson()).toList(),
      'missing_info': missingInfo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get top diagnosis (highest confidence)
  Diagnosis? get topDiagnosis =>
      diagnoses.isNotEmpty ? diagnoses.first : null;

  /// Get sorted diagnoses (by confidence descending)
  List<Diagnosis> get sortedDiagnoses {
    final sorted = List<Diagnosis>.from(diagnoses);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted;
  }
}

/// Follow-up Q&A pair
class FollowupQA {
  final String question;
  final String answer;
  final DateTime askedAt;

  FollowupQA({
    required this.question,
    required this.answer,
    required this.askedAt,
  });

  factory FollowupQA.fromJson(Map<String, dynamic> json) {
    return FollowupQA(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      askedAt: json['asked_at'] != null
          ? DateTime.parse(json['asked_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'asked_at': askedAt.toIso8601String(),
    };
  }
}
