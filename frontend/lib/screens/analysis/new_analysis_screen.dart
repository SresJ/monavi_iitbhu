import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/patient_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../models/patient.dart';
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../widgets/buttons/clinical_button.dart';
import '../../widgets/loading/clinical_loading.dart';

class NewAnalysisScreen extends StatefulWidget {
  final Patient? preselectedPatient;

  const NewAnalysisScreen({super.key, this.preselectedPatient});

  @override
  State<NewAnalysisScreen> createState() => _NewAnalysisScreenState();
}

class _NewAnalysisScreenState extends State<NewAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicalNotesController = TextEditingController();

  Patient? _selectedPatient;
  final List<PlatformFile> _audioFiles = [];
  final List<PlatformFile> _pdfFiles = [];
  final List<XFile> _imageFiles = [];
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.preselectedPatient;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatients();
    });
  }

  @override
  void dispose() {
    _clinicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    if (_selectedPatient == null) {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      await patientProvider.fetchPatients();
    }
  }

  Future<void> _pickAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        withData: true, // Important for web: loads file bytes
      );

      if (result != null) {
        setState(() {
          _audioFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Failed to pick audio files: $e');
    }
  }

  Future<void> _pickPDFFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true, // Important for web: loads file bytes
      );

      if (result != null) {
        setState(() {
          _pdfFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showError('Failed to pick PDF files: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _imageFiles.add(image);
        });
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(images);
        });
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  void _removeAudioFile(int index) {
    setState(() {
      _audioFiles.removeAt(index);
    });
  }

  void _removePDFFile(int index) {
    setState(() {
      _pdfFiles.removeAt(index);
    });
  }

  void _removeImageFile(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _handleAnalyze() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      _showError('Please select a patient');
      return;
    }

    if (_clinicalNotesController.text.trim().isEmpty &&
        _audioFiles.isEmpty &&
        _pdfFiles.isEmpty &&
        _imageFiles.isEmpty) {
      _showError('Please provide clinical notes or upload files');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final analysisProvider = Provider.of<AnalysisProvider>(
        context,
        listen: false,
      );

      final analysisId = await analysisProvider.createAnalysisWithFiles(
        patientId: _selectedPatient!.patientId,
        typedText: _clinicalNotesController.text.trim(),
        audioFiles: _audioFiles,
        pdfFiles: _pdfFiles,
        imageFiles: _imageFiles,
      );

      setState(() => _isAnalyzing = false);

      if (analysisId != null && mounted) {
        Navigator.pushReplacementNamed(context, '/analysis/$analysisId');
      } else if (mounted) {
        _showError(
          analysisProvider.errorMessage ?? 'Failed to create analysis',
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showError('Error creating analysis: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: DesignTokens.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ClinicalLoading(),
              const SizedBox(height: DesignTokens.spaceXl),
              Text(
                'Analyzing Clinical Data...',
                style: DesignTokens.headingSmall,
              ),
              const SizedBox(height: DesignTokens.spaceXs),
              Text(
                'This may take a minute',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: DesignTokens.voidBlack,
      appBar: AppBar(
        backgroundColor: DesignTokens.surfaceBlack,
        title: Text('New Analysis', style: DesignTokens.headingSmall),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = Breakpoints.isCompactWidth(constraints.maxWidth);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              DesignTokens.spaceLg,
              DesignTokens.spaceLg,
              DesignTokens.spaceLg,
              DesignTokens.spaceLg + bottomInset,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Clinical Analysis',
                    style: compact
                        ? DesignTokens.headingSmall
                        : DesignTokens.headingMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  Text(
                    'Enter clinical notes and upload relevant files',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),
                  _buildPatientSelection(compact: compact),
                  const SizedBox(height: DesignTokens.spaceXl),
                  _buildClinicalNotes(compact: compact),
                  const SizedBox(height: DesignTokens.spaceXl),
                  _buildFileUploads(compact: compact),
                  const SizedBox(height: DesignTokens.spaceXl),
                  _buildAnalyzeButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientSelection({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Patient', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceMd),
          if (widget.preselectedPatient != null)
            _buildSelectedPatientCard(widget.preselectedPatient!)
          else
            Consumer<PatientProvider>(
              builder: (context, patientProvider, child) {
                if (patientProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (patientProvider.patients.isEmpty) {
                  return Text(
                    'No patients available. Create a patient first.',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  );
                }

                return DropdownButtonFormField<Patient>(
                  initialValue: _selectedPatient,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: DesignTokens.surfaceBlack,
                    border: OutlineInputBorder(
                      borderRadius: DesignTokens.radiusMd,
                      borderSide: BorderSide(color: DesignTokens.borderGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: DesignTokens.radiusMd,
                      borderSide: BorderSide(color: DesignTokens.borderGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: DesignTokens.radiusMd,
                      borderSide: BorderSide(color: DesignTokens.medicalBlue),
                    ),
                  ),
                  dropdownColor: DesignTokens.cardBlack,
                  items: patientProvider.patients.map((patient) {
                    return DropdownMenuItem(
                      value: patient,
                      child: Text(
                        '${patient.fullName} - ${patient.patientId}',
                        style: DesignTokens.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (patient) {
                    setState(() {
                      _selectedPatient = patient;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a patient';
                    }
                    return null;
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPatientCard(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack,
        borderRadius: DesignTokens.radiusMd,
        border: Border.all(color: DesignTokens.medicalBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: DesignTokens.medicalGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient.initials,
                style: DesignTokens.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: DesignTokens.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  patient.patientId,
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.clinicalTeal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotes({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Notes', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceMd),
          TextFormField(
            controller: _clinicalNotesController,
            maxLines: compact ? 6 : 8,
            minLines: compact ? 4 : 5,
            style: DesignTokens.bodyMedium,
            decoration: InputDecoration(
              hintText:
                  'Enter patient symptoms, history, and observations...\nExample : Suffering from heart pain since 2 days',
              hintStyle: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textTertiary,
              ),
              filled: true,
              fillColor: DesignTokens.surfaceBlack,
              border: OutlineInputBorder(
                borderRadius: DesignTokens.radiusMd,
                borderSide: BorderSide(color: DesignTokens.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: DesignTokens.radiusMd,
                borderSide: BorderSide(color: DesignTokens.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: DesignTokens.radiusMd,
                borderSide: BorderSide(color: DesignTokens.medicalBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploads({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multimodal Files (Optional)', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceMd),

          // Audio Files
          _buildFileSection(
            compact,
            'Audio Files',
            Icons.mic_outlined,
            _audioFiles.map((f) => f.name).toList(),
            _removeAudioFile,
            _pickAudioFiles,
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // PDF Files
          _buildFileSection(
            compact,
            'PDF Documents',
            Icons.picture_as_pdf_outlined,
            _pdfFiles.map((f) => f.name).toList(),
            _removePDFFile,
            _pickPDFFiles,
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Image Files
          _buildImageSection(compact: compact),
        ],
      ),
    );
  }

  Widget _buildFileSection(
    bool compact,
    String title,
    IconData icon,
    List<String> files,
    Function(int) onRemove,
    VoidCallback onAdd,
  ) {
    final addButton = OutlinedButton.icon(
      onPressed: onAdd,
      icon: Icon(icon, color: DesignTokens.medicalBlue),
      label: Text(
        'Add $title',
        style: TextStyle(color: DesignTokens.medicalBlue),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: DesignTokens.medicalBlue),
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusMd),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DesignTokens.labelMedium),
        const SizedBox(height: DesignTokens.spaceXs),
        if (compact)
          SizedBox(width: double.infinity, child: addButton)
        else
          addButton,
        if (files.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spaceXs),
          ...files.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceBlack,
                  borderRadius: DesignTokens.radiusSm,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: DesignTokens.textSecondary),
                    const SizedBox(width: DesignTokens.spaceXs),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: DesignTokens.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: DesignTokens.error,
                      ),
                      onPressed: () => onRemove(entry.key),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildImageSection({required bool compact}) {
    final cameraBtn = SizedBox(
      width: compact ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: _pickImageFromCamera,
        icon: Icon(
          Icons.camera_alt_outlined,
          color: DesignTokens.medicalBlue,
        ),
        label: Text(
          'Camera',
          style: TextStyle(color: DesignTokens.medicalBlue),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: DesignTokens.medicalBlue),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radiusMd,
          ),
        ),
      ),
    );

    final galleryBtn = SizedBox(
      width: compact ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: _pickImageFromGallery,
        icon: Icon(
          Icons.photo_library_outlined,
          color: DesignTokens.medicalBlue,
        ),
        label: Text(
          'Gallery',
          style: TextStyle(color: DesignTokens.medicalBlue),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: DesignTokens.medicalBlue),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radiusMd,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medical Images', style: DesignTokens.labelMedium),
        const SizedBox(height: DesignTokens.spaceXs),
        if (compact) ...[
          cameraBtn,
          const SizedBox(height: DesignTokens.spaceSm),
          galleryBtn,
        ] else
          Row(
            children: [
              Expanded(child: cameraBtn),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(child: galleryBtn),
            ],
          ),
        if (_imageFiles.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          Wrap(
            spacing: DesignTokens.spaceXs,
            runSpacing: DesignTokens.spaceXs,
            children: _imageFiles.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: DesignTokens.radiusSm,
                    child: _buildImagePreview(entry.value),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeImageFile(entry.key),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: DesignTokens.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(XFile imageFile) {
    // Always use FutureBuilder with bytes - works on both web and mobile
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: 80,
          height: 80,
          color: DesignTokens.surfaceBlack,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignTokens.medicalBlue,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyzeButton() {
    return ClinicalButton(
      label: 'Analyze Clinical Data',
      onPressed: _handleAnalyze,
      icon: Icons.analytics_outlined,
      fullWidth: true,
    );
  }
}
