import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/app_theme.dart';
import '../models/question_model.dart';
import '../widgets/duo_button.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final Color categoryColor;
  final String categoryEmoji;
  final String categoryTitle;

  const ResultScreen({
    super.key,
    required this.result,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.categoryTitle,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.result.accuracy >= 60) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _confettiController.play();
        _starController.forward();
        HapticFeedback.heavyImpact();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        _starController.forward();
        HapticFeedback.mediumImpact();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.result.accuracy >= 70
          ? const Color(0xFFD7FFB8)
          : AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Result icon - Logo mascot
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getAccuracyColor().withValues(alpha: 0.4),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getAccuracyColor().withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'lib/image/logo_happy.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shake(hz: 2, offset: const Offset(0, 4), duration: 500.ms),

                  const SizedBox(height: 12),

                  // Stars
                  _buildStars()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 12),

                  // Result title
                  Text(
                    _getResultTitle(),
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                  const SizedBox(height: 6),

                  Text(
                    _getResultSubtitle(),
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 500.ms, delay: 450.ms),

                  const SizedBox(height: 28),

                  // Accuracy circle
                  CircularPercentIndicator(
                    radius: 75,
                    lineWidth: 14,
                    animation: true,
                    animationDuration: 1500,
                    percent: (widget.result.accuracy / 100).clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.result.accuracy.toInt()}%',
                          style: GoogleFonts.cairo(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: _getAccuracyColor(),
                          ),
                        ),
                        Text(
                          'الدقة',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    progressColor: _getAccuracyColor(),
                    backgroundColor:
                        _getAccuracyColor().withValues(alpha: 0.15),
                    circularStrokeCap: CircularStrokeCap.round,
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: 28),

                  // Stats card
                  _buildStatsCard()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // XP breakdown
                  _buildXpBreakdown()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 700.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 28),

                  // Buttons
                  _buildActionButtons()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),
                ],
              ),
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
              numberOfParticles: 30,
              gravity: 0.05,
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

  Widget _buildStars() {
    int stars = widget.result.stars;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isLit = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isLit ? Icons.star_rounded : Icons.star_border_rounded,
            color: isLit ? AppColors.gold : Colors.grey[300],
            size: i == 1 ? 48 : 38, // Middle star is bigger
          )
              .animate(delay: (400 + i * 200).ms)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
        );
      }),
    );
  }

  IconData _getResultIcon() {
    if (widget.result.isPerfect) return Icons.emoji_events_rounded;
    if (widget.result.accuracy >= 80) return Icons.star_rounded;
    if (widget.result.accuracy >= 60) return Icons.thumb_up_rounded;
    if (widget.result.accuracy >= 40) return Icons.fitness_center_rounded;
    return Icons.refresh_rounded;
  }

  String _getResultTitle() {
    if (widget.result.isPerfect) return 'مثالي!';
    if (widget.result.accuracy >= 80) return 'ممتاز!';
    if (widget.result.accuracy >= 60) return 'جيد جداً!';
    if (widget.result.accuracy >= 40) return 'لا بأس!';
    return 'حاول مرة أخرى';
  }

  String _getResultSubtitle() {
    if (widget.result.isPerfect) {
      return 'لقد أجبت على جميع الأسئلة بشكل صحيح!';
    }
    if (widget.result.accuracy >= 80) return 'أداء رائع! استمر في التقدم';
    if (widget.result.accuracy >= 60) return 'جهد جيد! يمكنك تحسين أدائك';
    if (widget.result.accuracy >= 40) return 'تحتاج لمزيد من التدريب';
    return 'لا تستسلم! التدريب يصنع المعجزات';
  }

  Color _getAccuracyColor() {
    if (widget.result.accuracy >= 80) return AppColors.correct;
    if (widget.result.accuracy >= 60) return AppColors.accent;
    if (widget.result.accuracy >= 40) return AppColors.streak;
    return AppColors.error;
  }

  Widget _buildStatsCard() {
    int mins = widget.result.timeTaken.inMinutes;
    int secs = widget.result.timeTaken.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.check_circle_rounded,
                  '${widget.result.correctAnswers}',
                  'صحيحة',
                  AppColors.correct,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  Icons.cancel_rounded,
                  '${widget.result.wrongAnswers}',
                  'خاطئة',
                  AppColors.error,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey[200], height: 28),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.local_fire_department_rounded,
                  '${widget.result.bestCombo}',
                  'أفضل كومبو',
                  AppColors.streak,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  Icons.timer_rounded,
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  'الوقت',
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildXpBreakdown() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'نقاط الخبرة المكتسبة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildXpRow('إجابات صحيحة', '+${widget.result.xpEarned}'),
          if (widget.result.bonusXpEarned > 0)
            _buildXpRow('مكافأة الصعوبة', '+${widget.result.bonusXpEarned}'),
          if (widget.result.comboBonus > 0)
            _buildXpRow('مكافأة الكومبو', '+${widget.result.comboBonus}'),
          const SizedBox(height: 8),
          Container(
            height: 1.5,
            color: AppColors.gold.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.goldDark,
                ),
              ),
              Text(
                '+${widget.result.totalXp} XP',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        DuoButton(
          text: 'حاول مرة أخرى',
          color: widget.categoryColor,
          icon: Icons.replay_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 12),
        DuoButton(
          text: 'العودة للرئيسية',
          color: AppColors.secondary,
          icon: Icons.home_rounded,
          isOutlined: true,
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
