import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../services/question_generator.dart';
import '../widgets/duo_button.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final Color categoryColor;
  final String categoryEmoji;
  final String categoryTitle;
  // Pass quiz info for retry
  final QuestionType? type;
  final Difficulty? difficulty;

  const ResultScreen({
    super.key,
    required this.result,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.categoryTitle,
    this.type,
    this.difficulty,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    final isGood = widget.result.accuracy >= 60;
    Future.delayed(Duration(milliseconds: isGood ? 500 : 200), () {
      if (!mounted) return;
      if (isGood) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    if (widget.result.accuracy >= 80) return AppColors.correct;
    if (widget.result.accuracy >= 60) return AppColors.accent;
    if (widget.result.accuracy >= 40) return AppColors.streak;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isGreat = widget.result.accuracy >= 70;

    return Scaffold(
      backgroundColor: isGreat ? const Color(0xFFD7FFB8) : AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        // Mascot + reaction
                        _buildMascotSection()
                            .animate()
                            .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 8),

                        // Stars
                        _buildStars()
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 250.ms),

                        const SizedBox(height: 10),

                        // Title
                        Text(
                          _title,
                          style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 4),

                        Text(
                          _subtitle,
                          style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                        const SizedBox(height: 24),

                        // Accuracy + Stats
                        _buildResultCard()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 450.ms)
                            .slideY(begin: 0.15, end: 0),

                        const SizedBox(height: 14),

                        // XP card
                        _buildXpCard()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 550.ms)
                            .slideY(begin: 0.15, end: 0),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom buttons
                _buildButtons()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 700.ms)
                    .slideY(begin: 0.3, end: 0),
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
              numberOfParticles: 25,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.gold, AppColors.purple],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MASCOT ====================
  Widget _buildMascotSection() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _accentColor.withValues(alpha: 0.4), width: 4),
        boxShadow: [BoxShadow(color: _accentColor.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            widget.result.accuracy >= 50 ? 'lib/image/logo_happy.png' : 'lib/image/logo_without_bg.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ==================== STARS ====================
  Widget _buildStars() {
    final stars = widget.result.stars;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final lit = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            lit ? Icons.star_rounded : Icons.star_border_rounded,
            color: lit ? AppColors.gold : Colors.grey[300],
            size: i == 1 ? 44 : 34,
          )
              .animate(delay: (350 + i * 150).ms)
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
        );
      }),
    );
  }

  // ==================== RESULT CARD ====================
  Widget _buildResultCard() {
    final mins = widget.result.timeTaken.inMinutes;
    final secs = widget.result.timeTaken.inSeconds % 60;
    final pct = widget.result.accuracy;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        children: [
          // Accuracy bar
          Row(
            children: [
              Text('الدقة', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 10),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Stack(
                      children: [
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          widthFactor: (pct / 100).clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(9),
                              border: Border(bottom: BorderSide(color: _accentColor.withValues(alpha: 0.7), width: 2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${pct.toInt()}%', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: _accentColor), textDirection: TextDirection.ltr),
            ],
          ),

          const SizedBox(height: 16),

          // 4 stat boxes
          Row(
            children: [
              _statBox(Icons.check_circle_rounded, '${widget.result.correctAnswers}', 'صح', AppColors.correct),
              const SizedBox(width: 8),
              _statBox(Icons.cancel_rounded, '${widget.result.wrongAnswers}', 'خطأ', AppColors.error),
              const SizedBox(width: 8),
              _statBox(Icons.local_fire_department_rounded, '${widget.result.bestCombo}', 'كومبو', AppColors.streak),
              const SizedBox(width: 8),
              _statBox(Icons.timer_rounded, '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}', 'الوقت', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900, color: color), textDirection: TextDirection.ltr),
            Text(label, style: GoogleFonts.cairo(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ==================== XP CARD ====================
  Widget _buildXpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.1), AppColors.gold.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 22),
              const SizedBox(width: 6),
              Text('نقاط الخبرة', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),

          // XP rows
          _xpRow('إجابات صحيحة', '+${widget.result.xpEarned}'),
          if (widget.result.bonusXpEarned > 0) _xpRow('مكافأة الصعوبة', '+${widget.result.bonusXpEarned}'),
          if (widget.result.comboBonus > 0) _xpRow('مكافأة الكومبو', '+${widget.result.comboBonus}'),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(height: 1, color: AppColors.gold.withValues(alpha: 0.25)),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المجموع', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('+${widget.result.totalXp} XP', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xpRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(val, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldDark)),
        ],
      ),
    );
  }

  // ==================== BUTTONS ====================
  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: widget.result.accuracy >= 70 ? const Color(0xFFD7FFB8) : AppColors.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Try Again - navigates to a new quiz
          DuoButton(
            text: 'حاول مرة أخرى',
            color: widget.categoryColor,
            icon: Icons.replay_rounded,
            onPressed: _retry,
          ),
          const SizedBox(height: 10),
          // Home
          DuoButton(
            text: 'العودة للرئيسية',
            color: AppColors.secondary,
            icon: Icons.home_rounded,
            isOutlined: true,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  void _retry() {
    HapticFeedback.lightImpact();
    if (widget.type != null && widget.difficulty != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => QuizScreen(
            type: widget.type!,
            difficulty: widget.difficulty!,
            categoryTitle: widget.categoryTitle,
            categoryColor: widget.categoryColor,
            categoryEmoji: widget.categoryEmoji,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      // Fallback: go back to first screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // ==================== HELPERS ====================
  String get _title {
    if (widget.result.isPerfect) return '🏆 مثالي!';
    if (widget.result.accuracy >= 80) return '⭐ ممتاز!';
    if (widget.result.accuracy >= 60) return '👏 جيد جداً!';
    if (widget.result.accuracy >= 40) return '💪 لا بأس!';
    return '🔄 حاول مرة أخرى';
  }

  String get _subtitle {
    if (widget.result.isPerfect) return 'لقد أجبت على جميع الأسئلة بشكل صحيح!';
    if (widget.result.accuracy >= 80) return 'أداء رائع! استمر في التقدم';
    if (widget.result.accuracy >= 60) return 'جهد جيد! يمكنك تحسين أدائك';
    if (widget.result.accuracy >= 40) return 'تحتاج لمزيد من التدريب';
    return 'لا تستسلم! التدريب يصنع المعجزات';
  }
}
