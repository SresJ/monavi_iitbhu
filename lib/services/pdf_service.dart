import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/analysis.dart';

class PdfService {
  static Future<void> generateAndShareAnalysisReport(Analysis analysis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(analysis),
          pw.SizedBox(height: 20),
          _buildPatientInfo(analysis),
          pw.SizedBox(height: 20),
          _buildClinicalSummary(analysis.summary),
          pw.SizedBox(height: 20),
          _buildDifferentialDiagnoses(analysis.sortedDiagnoses),
          if (analysis.diagnosticTests.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildRecommendedTests(analysis.diagnosticTests),
          ],
          if (analysis.missingInfo.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildMissingInfo(analysis.missingInfo),
          ],
          pw.SizedBox(height: 30),
          _buildDisclaimer(),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'clinical_analysis_${analysis.analysisId}.pdf',
    );
  }

  static pw.Widget _buildHeader(Analysis analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A5F'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Clinical AI Analysis Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'AI-Assisted Differential Diagnosis',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey300,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'ID: ${analysis.analysisId.toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal200,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormat('MMM dd, yyyy HH:mm').format(analysis.createdAt),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(Analysis analysis) {
    final summary = analysis.summary;
    final infoParts = <String>[];
    if (summary.age != null) infoParts.add('${summary.age} years old');
    if (summary.sex != null) infoParts.add(_capitalize(summary.sex!));

    if (infoParts.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Patient: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.Text(infoParts.join(' | '), style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _buildClinicalSummary(Summary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Clinical Summary'),
        pw.SizedBox(height: 8),
        if (summary.chiefComplaint != null)
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0F9FF'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Chief Complaint',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 4),
                pw.Text(_capitalize(summary.chiefComplaint!), style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
        if (summary.associatedSymptoms.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('Associated Symptoms:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: summary.associatedSymptoms.map((s) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Text(_capitalize(s), style: const pw.TextStyle(fontSize: 9)),
            )).toList(),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildDifferentialDiagnoses(List<Diagnosis> diagnoses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Differential Diagnoses'),
        pw.SizedBox(height: 8),
        ...diagnoses.asMap().entries.map((entry) {
          final index = entry.key;
          final d = entry.value;
          final color = _getConfidenceColor(d.confidenceLevel);

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: color, width: 1.5),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${index + 1}. ${_capitalize(d.diagnosisName)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: color,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        '${d.confidencePercentage}% ${d.confidenceLevel.toUpperCase()}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ),
                  ],
                ),
                if (d.triggeringSymptoms.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Triggering Symptoms:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    d.triggeringSymptoms.map(_capitalize).join(', '),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
                if (d.confidenceRationale.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text('Rationale:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  ...d.confidenceRationale.take(2).map((r) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, top: 2),
                    child: pw.Text('• $r', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  )),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildRecommendedTests(List<DiagnosticTest> tests) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Diagnostic Tests'),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F0FDFA'),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.teal300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: tests.map((t) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 6,
                    height: 6,
                    margin: const pw.EdgeInsets.only(top: 4, right: 8),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.teal600,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(_capitalize(t.testName), style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMissingInfo(List<String> missingInfo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Missing Information'),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FFFBEB'),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.amber300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: missingInfo.map((info) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.amber700)),
                  pw.Expanded(
                    child: pw.Text(_capitalize(info), style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 16,
            height: 16,
            margin: const pw.EdgeInsets.only(right: 8),
            child: pw.Text('*', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
          ),
          pw.Expanded(
            child: pw.Text(
              'This AI-generated analysis is intended to support clinical decision-making and does not replace professional medical judgment. Always correlate with clinical findings and patient history.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A5F'),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} | Generated by Clinical AI',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }

  static PdfColor _getConfidenceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return PdfColors.green600;
      case 'medium':
        return PdfColors.amber600;
      default:
        return PdfColors.red400;
    }
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
