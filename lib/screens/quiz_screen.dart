import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../services/question_generator.dart';
import '../services/storage_service.dart';
import '../widgets/duo_button.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuestionType type;
  final Difficulty difficulty;
  final String categoryTitle;
  final Color categoryColor;
  final String categoryEmoji;
  final List<Question>? customQuestions;

  /// When true, wrong answers are re-asked until all correct (multiplication table mode)
  final bool isTableMode;

  const QuizScreen({
    super.key,
    required this.type,
    required this.difficulty,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryEmoji,
    this.customQuestions,
    this.isTableMode = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final QuestionGenerator _generator = QuestionGenerator();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _streak = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _totalBonusXp = 0;
  int _comboBonus = 0;
  double _mastery = 0.0;
  bool _isLoading = true;
  bool _answered = false;
  bool _isCorrect = false;
  String _feedbackText = '';

  // Table mode: retry logic
  final List<Question> _retryQueue = [];
  int _totalAnswered = 0;
  bool _inRetryPhase = false;
  int _originalQuestionCount = 0;

  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _comboController;

  // Timer
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _prepareQuiz();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  Future<void> _loadMeta() async {
    final progress = await StorageService.getUserProgress();
    if (!mounted) return;
    setState(() {
      _streak = progress.streak;
    });
  }

  Future<void> _prepareQuiz() async {
    await _loadMeta();

    if (widget.customQuestions != null) {
      _questions = List.from(widget.customQuestions!);
      _originalQuestionCount = _questions.length;
      _startTimer();
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _mastery = await StorageService.getCategoryMastery(widget.type);
    _questions = _generator.generateAdaptiveQuestionsByType(
      type: widget.type,
      targetDifficulty: widget.difficulty,
      mastery: _mastery,
      count: AppConstants.questionsPerLesson,
    );

    _originalQuestionCount = _questions.length;
    _startTimer();
    if (!mounted) return;
    setState(() => _isLoading = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  IconData _getCategoryIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multiplication:
        return Icons.close_rounded;
      case QuestionType.addition:
        return Icons.add_rounded;
      case QuestionType.subtraction:
        return Icons.remove_rounded;
      case QuestionType.division:
        return Icons.percent_rounded;
      case QuestionType.sequence:
        return Icons.timeline_rounded;
      case QuestionType.mentalMath:
        return Icons.psychology_rounded;
    }
  }

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'سهل';
      case Difficulty.medium:
        return 'متوسط';
      case Difficulty.hard:
        return 'صعب';
    }
  }

  double _getComboMultiplier() {
    if (_combo >= AppConstants.comboThreshold8) {
      return AppConstants.comboMultiplier8;
    }
    if (_combo >= AppConstants.comboThreshold5) {
      return AppConstants.comboMultiplier5;
    }
    if (_combo >= AppConstants.comboThreshold3) {
      return AppConstants.comboMultiplier3;
    }
    return 1.0;
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _comboController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _checkAnswer() {
    if (_answered || _answerController.text.trim().isEmpty) return;

    String userAnswer = _answerController.text.trim();
    String correctAnswer = _questions[_currentIndex].correctAnswer.trim();

    setState(() {
      _answered = true;
      _totalAnswered++;
      _isCorrect = userAnswer == correctAnswer;

      if (_isCorrect) {
        _correctCount++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        _totalBonusXp += _questions[_currentIndex].bonusXp;

        final multiplier = _getComboMultiplier();
        if (multiplier > 1.0) {
          _comboBonus += (AppConstants.xpPerCorrect * (multiplier - 1.0))
              .round();
        }

        _feedbackText = _getCorrectFeedback();
        HapticFeedback.lightImpact();
        _pulseController.forward(from: 0);

        if (_combo >= 3) {
          _comboController.forward(from: 0);
        }
        if (_combo >= 5) {
          _confettiController.play();
        }
      } else {
        _wrongCount++;
        _combo = 0;
        _feedbackText = 'الإجابة الصحيحة: $correctAnswer';
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);

        // In table mode, queue wrong answers for retry
        if (widget.isTableMode) {
          _retryQueue.add(_questions[_currentIndex]);
        }
      }
    });
  }

  String _getCorrectFeedback() {
    if (_combo >= 8) return 'خارق!';
    if (_combo >= 5) return 'مذهل! سلسلة $_combo!';
    if (_combo >= 3) return 'رائع! كومبو $_combo!';

    List<String> feedbacks = [
      'ممتاز!',
      'رائع!',
      'أحسنت!',
      'صحيح!',
      'عبقري!',
      'مذهل!',
      'بطل!',
    ];
    feedbacks.shuffle();
    return feedbacks.first;
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _isCorrect = false;
        _feedbackText = '';
        _answerController.clear();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    } else if (widget.isTableMode && _retryQueue.isNotEmpty) {
      // Table mode: start retry phase with wrong questions
      setState(() {
        _inRetryPhase = true;
        _questions = List.from(_retryQueue);
        _retryQueue.clear();
        _questions.shuffle();
        _currentIndex = 0;
        _answered = false;
        _isCorrect = false;
        _feedbackText = '';
        _answerController.clear();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    final result = QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: _correctCount,
      wrongAnswers: _wrongCount,
      xpEarned: _correctCount * AppConstants.xpPerCorrect,
      bonusXpEarned: _totalBonusXp,
      comboBonus: _comboBonus,
      bestCombo: _bestCombo,
      timeTaken: Duration(seconds: _secondsElapsed),
      type: widget.type,
      difficulty: widget.difficulty,
    );

    await StorageService.addXp(result.totalXp);
    await StorageService.addScore(_correctCount * 10);
    await StorageService.saveQuizPerformance(
      type: widget.type,
      difficulty: widget.difficulty,
      correctAnswers: _correctCount,
      totalQuestions: _questions.length,
    );
    await StorageService.trackQuizCompletion(
      correctAnswers: _correctCount,
      totalQuestions: _questions.length,
      bestCombo: _bestCombo,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          result: result,
          categoryColor: widget.categoryColor,
          categoryEmoji: widget.categoryEmoji,
          categoryTitle: widget.categoryTitle,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// Splits question text into Arabic label and LTR math expression
  /// Auto-sizes font based on text length to keep everything on one line
  Widget _buildQuestionText(String text) {
    // Auto-size helper: shorter text = bigger font
    double _mathFontSize(String t) {
      final len = t.length;
      if (len <= 15) return 30;
      if (len <= 22) return 26;
      if (len <= 30) return 22;
      if (len <= 40) return 18;
      return 16;
    }
    double _arabicFontSize(String t) {
      final len = t.length;
      if (len <= 20) return 24;
      if (len <= 30) return 20;
      if (len <= 45) return 17;
      return 15;
    }

    // Check if the question has a label prefix (like "أكمل السلسلة:\n...")
    if (text.contains(':\n')) {
      final parts = text.split(':\n');
      return Column(
        children: [
          Text(
            '${parts[0]}:',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                parts[1],
                style: GoogleFonts.cairo(
                  fontSize: _mathFontSize(parts[1]),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    }

    // For questions that start with Arabic text (like "ما ضعف..." or "كم تساوي..." or "عدد..." or "حاصل..." or "مجموع...")
    final arabicStarts = ['ما ', 'كم ', 'عدد ', 'حاصل ', 'مجموع ', 'ثلث', 'نصف', 'ربع', 'خمس', 'سدس', 'سبع', 'ثمن', 'تسع', 'عشر'];
    final isArabic = arabicStarts.any((s) => text.startsWith(s));
    if (isArabic) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: _arabicFontSize(text),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          maxLines: 1,
        ),
      );
    }

    // For pure math expressions (like "5 × 3 = ؟"), render LTR with auto-size
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: _mathFontSize(text),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.4,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.categoryColor.withValues(alpha: 0.08),
                AppColors.background,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.categoryColor.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: widget.categoryColor.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'lib/image/logo_without_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 0.9, end: 1.1, duration: 800.ms),
                const SizedBox(height: 20),
                Text(
                  'نجهّز لك أسئلة ذكية...',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      backgroundColor: widget.categoryColor.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: AlwaysStoppedAnimation(widget.categoryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // In table mode, track progress against original count
    double progress;
    if (widget.isTableMode) {
      progress = (_correctCount / _originalQuestionCount).clamp(0.0, 1.0);
    } else {
      progress = (_currentIndex + 1) / _questions.length;
    }
    Question currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: _answered
          ? (_isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFDF))
          : AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(progress),

                // Question area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Retry phase banner
                        if (_inRetryPhase)
                          Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.replay_rounded,
                                      color: AppColors.accent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'إعادة الأسئلة الخاطئة (${_questions.length} متبقي)',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.3, end: 0),

                        // Timer & info row
                        _buildInfoRow().animate().fadeIn(duration: 400.ms),

                        // Combo indicator
                        if (_combo >= 3 && !_answered)
                          _buildComboIndicator()
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                              ),

                        const SizedBox(height: 20),

                        // Question card
                        _buildQuestionCard(currentQ),

                        const SizedBox(height: 24),

                        // Answer input
                        _buildAnswerInput(),

                        const SizedBox(height: 12),

                        // Hint
                        if (!_answered && currentQ.hint != null)
                          _buildHintButton(currentQ.hint!),

                        // Feedback
                        if (_answered)
                          _buildFeedback(currentQ)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                _buildBottomButton(),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                AppColors.gold,
                AppColors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: _showExitDialog,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: Color(0xFF777777),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar - Duolingo style (always fills left to right)
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.categoryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.getShadow(widget.categoryColor),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Streak indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.streak.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.streak,
                  size: 16,
                ),
                if (_streak > 0) ...[
                  const SizedBox(width: 3),
                  Text(
                    '$_streak',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.streak,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    int mins = _secondsElapsed ~/ 60;
    int secs = _secondsElapsed % 60;

    final questionLabel = widget.isTableMode
        ? '$_correctCount/$_originalQuestionCount'
        : '${_currentIndex + 1}/${_questions.length}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInfoChip(
            Icons.timer_rounded,
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          _buildInfoChip(
            widget.isTableMode
                ? Icons.check_circle_outline_rounded
                : Icons.format_list_numbered_rounded,
            questionLabel,
            widget.categoryColor,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.isTableMode
                  ? (widget.categoryTitle)
                  : _difficultyLabel(widget.difficulty),
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.categoryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboIndicator() {
    final multiplier = _getComboMultiplier();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _combo >= 8
              ? [const Color(0xFFFF6B35), const Color(0xFFFF3D00)]
              : _combo >= 5
              ? [const Color(0xFFFF9600), const Color(0xFFFF6B00)]
              : [AppColors.gold, const Color(0xFFFFC107)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          bottom: BorderSide(
            color: _combo >= 8
                ? const Color(0xFFCC2E00)
                : _combo >= 5
                ? const Color(0xFFCC5500)
                : AppColors.goldDark,
            width: 3,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _combo >= 8
                ? Icons.whatshot_rounded
                : _combo >= 5
                ? Icons.local_fire_department_rounded
                : Icons.bolt_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            'كومبو $_combo! ×${multiplier.toStringAsFixed(1)}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        double shakeOffset = 0;
        if (_shakeController.isAnimating) {
          shakeOffset =
              10 *
              (0.5 - _shakeController.value).abs() *
              (_shakeController.value < 0.25 ? 1 : -1);
        }
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child:
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Category icon in circle
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(widget.type),
                          size: 26,
                          color: widget.categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question text with proper directionality
                    _buildQuestionText(question.questionText),

                    // Bonus XP indicator
                    if (question.bonusXp > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.goldDark,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${question.bonusXp} XP',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }

  Widget _buildAnswerInput() {
    final borderColor = _answered
        ? (_isCorrect ? AppColors.correct : AppColors.wrong)
        : const Color(0xFFE5E5E5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          controller: _answerController,
          focusNode: _focusNode,
          autofocus: true,
          enabled: !_answered,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.cairo(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _answered
                ? (_isCorrect ? AppColors.correct : AppColors.wrong)
                : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '؟',
            hintStyle: GoogleFonts.cairo(
              fontSize: 28,
              color: AppColors.textLight,
              fontWeight: FontWeight.w800,
            ),
            filled: true,
            fillColor: _answered
                ? (_isCorrect ? AppColors.correctBg : AppColors.wrongBg)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor, width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor, width: 2.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: borderColor, width: 2.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: widget.categoryColor, width: 2.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            suffixIcon: _answered
                ? Icon(
                    _isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _isCorrect ? AppColors.correct : AppColors.wrong,
                    size: 26,
                  )
                : null,
          ),
          onSubmitted: (_) => _checkAnswer(),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildHintButton(String hint) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hint,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'تلميح',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(Question question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isCorrect ? AppColors.correctBg : AppColors.wrongBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? AppColors.correct : AppColors.wrong,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (_isCorrect ? AppColors.correct : AppColors.wrong)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: _isCorrect ? AppColors.correct : AppColors.wrong,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _feedbackText,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _isCorrect ? AppColors.correct : AppColors.wrong,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          if (!_isCorrect && question.explanation != null) ...[
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                question.explanation!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final color = _answered
        ? (_isCorrect ? AppColors.correct : AppColors.wrong)
        : widget.categoryColor;
    final shadowColor = AppColors.getShadow(color);

    String text;
    if (!_answered) {
      text = 'تحقق';
    } else if (_currentIndex < _questions.length - 1) {
      text = 'التالي';
    } else if (widget.isTableMode &&
        (_retryQueue.isNotEmpty || (!_isCorrect))) {
      // In table mode, if we have retries or just got wrong on the last question
      text = 'إعادة الخاطئة';
    } else {
      text = 'عرض النتائج';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: DuoButton(
        text: text,
        color: color,
        shadowColor: shadowColor,
        onPressed: _answered ? _nextQuestion : _checkAnswer,
        isDisabled: !_answered && _answerController.text.trim().isEmpty,
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'هل تريد الخروج؟',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'سيتم فقدان التقدم الحالي',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'متابعة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'خروج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
