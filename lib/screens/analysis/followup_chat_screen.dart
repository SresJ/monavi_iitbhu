import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../providers/analysis_provider.dart';
import '../../models/analysis.dart';
import '../../config/design_tokens.dart';
import '../../widgets/feedback/clinician_feedback.dart';

/// Medical facts for loading screen
const List<String> _medicalFacts = [
  'The human body has over 600 muscles',
  'Your heart beats about 100,000 times per day',
  'The brain uses 20% of the body\'s oxygen',
  'Red blood cells live for about 120 days',
  'The liver performs over 500 functions',
  'Adults have 206 bones in their body',
  'The small intestine is about 20 feet long',
  'Your nose can detect over 1 trillion scents',
  'The cornea is the only tissue without blood vessels',
  'Nerve impulses travel at 250 mph',
];

class FollowupChatScreen extends StatefulWidget {
  final String analysisId;

  const FollowupChatScreen({super.key, required this.analysisId});

  @override
  State<FollowupChatScreen> createState() => _FollowupChatScreenState();
}

class _FollowupChatScreenState extends State<FollowupChatScreen>
    with TickerProviderStateMixin {
  final _questionController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _typingController;

  bool _isLoading = true;
  bool _isAsking = false;
  bool _isFocused = false;
  Analysis? _analysis;
  String _currentFact = '';
  String? _pendingQuestion; // For optimistic UI

  // Feedback state for each chat message (keyed by question text for uniqueness)
  final Map<String, FeedbackState> _feedbackStates = {};

  FeedbackState _getFeedbackState(String question) {
    return _feedbackStates[question] ?? const FeedbackState();
  }

  void _handleAccurateFeedback(String question) {
    setState(() {
      _feedbackStates[question] = const FeedbackState(
        feedbackSubmitted: true,
        feedbackType: 'accurate',
      );
    });
  }

  void _handleNeedsCorrectionFeedback(String question) {
    showFeedbackCorrectionModal(
      context,
      onSubmit: (inaccuracy, correction, tag) {
        setState(() {
          _feedbackStates[question] = FeedbackState(
            feedbackSubmitted: true,
            feedbackType: 'needs_correction',
            inaccuracyDescription: inaccuracy,
            correctedInput: correction,
            selectedTag: tag,
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _currentFact = _medicalFacts[math.Random().nextInt(_medicalFacts.length)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AnalysisProvider>(context, listen: false);

      // Clear old history first to prevent stale data
      provider.clearFollowupHistory();

      // Load in parallel for speed
      final results = await Future.wait([
        provider.getAnalysisById(widget.analysisId),
        provider.getFollowupHistory(widget.analysisId),
      ]);

      if (mounted) {
        setState(() {
          _analysis = results[0] as Analysis?;
          _isLoading = false;
        });
        // Small delay before scroll to ensure list is built
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load');
      }
    }
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isAsking) return;

    // Clear input immediately for better UX
    _questionController.clear();

    setState(() {
      _isAsking = true;
      _pendingQuestion = question;
    });
    _scrollToBottom();

    try {
      final provider = Provider.of<AnalysisProvider>(context, listen: false);

      final qa = await provider.askFollowupQuestion(
        analysisId: widget.analysisId,
        question: question,
      );

      if (mounted) {
        setState(() {
          _isAsking = false;
          _pendingQuestion = null;
        });

        if (qa == null) {
          _showError(provider.errorMessage ?? 'Failed to get answer');
        }
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAsking = false;
          _pendingQuestion = null;
        });
        _showError('Error: ${e.toString().split(':').last.trim()}');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: DesignTokens.confidenceLow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showError('Could not open link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    if (_analysis != null && !_isLoading) _buildAnalysisBanner(),
                  ],
                ),
              ),
              Expanded(child: _buildChatArea()),
              SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: _buildInputArea(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -60 + math.sin(_orbitController.value * 2 * math.pi) * 35,
              top: 80 + math.cos(_orbitController.value * 2 * math.pi) * 35,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.15),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -80 + math.cos(_orbitController.value * 2 * math.pi + 1.5) * 40,
              bottom: 200 + math.sin(_orbitController.value * 2 * math.pi + 1.5) * 40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.clinicalTeal.withOpacity(0.12),
                      DesignTokens.clinicalTeal.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(5, (index) {
            final x = (index % 3) * 130.0 + 50;
            final y = (index ~/ 3) * 300.0 + 200 +
                math.sin((_floatController.value + index * 0.15) * 2 * math.pi) * 12;
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.clinicalTeal.withOpacity(0.25),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.cardBlack.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.arrow_left, color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: DesignTokens.medicalGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.message_question, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow-Up Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_analysis != null)
                  Text(
                    _capitalizeFirst(_analysis!.summary.chiefComplaint ?? 'Analysis'),
                    style: TextStyle(color: DesignTokens.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisBanner() {
    final topDiag = _analysis!.topDiagnosis;
    if (topDiag == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.chart_square, color: DesignTokens.medicalBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _capitalizeFirst(topDiag.diagnosisName),
              style: TextStyle(
                color: DesignTokens.getConfidenceColor(topDiag.confidenceLevel),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.getConfidenceColor(topDiag.confidenceLevel).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${topDiag.confidencePercentage}%',
              style: TextStyle(
                color: DesignTokens.getConfidenceColor(topDiag.confidenceLevel),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        final history = provider.followupHistory;

        if (history.isEmpty && _pendingQuestion == null) {
          return _buildEmptyState();
        }

        final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + keyboardBottom),
          itemCount: history.length + (_pendingQuestion != null ? 1 : 0),
          itemBuilder: (context, index) {
            // Show pending question at the end
            if (_pendingQuestion != null && index == history.length) {
              return _buildPendingMessage();
            }
            return _buildChatMessage(history[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: DesignTokens.medicalGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.medicalBlue.withOpacity(0.2 + _pulseController.value * 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Iconsax.message_text, size: 32, color: Colors.white),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Chat...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.cardBlack.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Iconsax.lamp_on, color: DesignTokens.clinicalTeal, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _currentFact,
                    style: TextStyle(color: DesignTokens.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState() {
    final suggestions = ['Explain the diagnosis', 'What tests are needed?', 'Treatment options?'];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.message_text, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start A Conversation',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask questions about the analysis',
              style: TextStyle(color: DesignTokens.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((s) => GestureDetector(
                onTap: () {
                  _questionController.text = s;
                  _focusNode.requestFocus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesignTokens.medicalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DesignTokens.medicalBlue.withOpacity(0.25)),
                  ),
                  child: Text(s, style: TextStyle(color: DesignTokens.medicalBlue, fontSize: 12)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // User's pending question
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                _pendingQuestion!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // AI typing indicator
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignTokens.clinicalTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.cpu, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.cardBlack.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildTypingIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(FollowupQA qa) {
    final feedbackState = _getFeedbackState(qa.question);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User question
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(qa.question, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(qa.askedAt),
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // AI answer
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignTokens.clinicalTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.cpu, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.cardBlack.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: DesignTokens.clinicalTeal.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRichText(qa.answer),

                        // Feedback section
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: DesignTokens.borderGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),

                        // Show badge and confirmation if submitted, otherwise show actions
                        if (feedbackState.feedbackSubmitted) ...[
                          const ClinicianReviewedBadge(),
                          const FeedbackConfirmation(),
                        ] else
                          ClinicianFeedbackActions(
                            feedbackState: feedbackState,
                            onAccurate: () => _handleAccurateFeedback(qa.question),
                            onNeedsCorrection: () => _handleNeedsCorrectionFeedback(qa.question),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build rich text with clickable links
  Widget _buildRichText(String text) {
    final urlRegex = RegExp(r'https?://[^\s\)]+');
    final matches = urlRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(text, style: TextStyle(color: DesignTokens.textPrimary, fontSize: 14));
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: DesignTokens.textPrimary, fontSize: 14),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          color: DesignTokens.medicalBlue,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: DesignTokens.textPrimary, fontSize: 14),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack,
        border: Border(top: BorderSide(color: DesignTokens.borderGray.withOpacity(0.3))),
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                decoration: BoxDecoration(
                  color: DesignTokens.cardBlack.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFocused
                        ? DesignTokens.medicalBlue.withOpacity(0.4)
                        : DesignTokens.borderGray.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _questionController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  enabled: !_isAsking,
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    hintStyle: TextStyle(color: DesignTokens.textTertiary, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _askQuestion(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _askQuestion,
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: _questionController.text.trim().isNotEmpty
                      ? DesignTokens.medicalGradient
                      : null,
                  color: _questionController.text.trim().isEmpty
                      ? DesignTokens.borderGray.withOpacity(0.4)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isAsking
                      ? _buildTypingIndicator()
                      : Icon(
                          Iconsax.send_1,
                          color: _questionController.text.trim().isEmpty
                              ? DesignTokens.textTertiary
                              : Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildTypingIndicator() {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = ((_typingController.value + index * 0.2) % 1.0);
            final scale = 0.5 + math.sin(value * math.pi) * 0.5;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 5 * scale,
              height: 5 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5 + scale * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
