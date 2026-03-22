import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';
import '../models/question_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  UserProgress _progress = UserProgress();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await StorageService.getUserProgress();
    if (mounted) {
      setState(() => _progress = progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'الإحصائيات',
                  style: GoogleFonts.cairo( 
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.analytics_rounded, size: 26, color: AppColors.purple),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 20),

            // Level & XP card
            _buildLevelCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 14),

            // Stats grid
            _buildStatsGrid()
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 14),

            // Performance card
            _buildPerformanceCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Achievements section
            Row(
              children: [
                Text(
                  'الإنجازات',
                  style: GoogleFonts.cairo( 
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.military_tech_rounded, size: 22, color: AppColors.gold),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

            const SizedBox(height: 12),

            _buildAchievements()
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Reset button
            Center(
              child: GestureDetector(
                onTap: _showResetDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        'إعادة تعيين التقدم',
                        style: GoogleFonts.cairo( 
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    double xpProgress =
        (_progress.xp / AppConstants.xpPerLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF4A3580), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 42,
            lineWidth: 7,
            animation: true,
            animationDuration: 1200,
            percent: xpProgress,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_progress.level}',
                  style: GoogleFonts.cairo( 
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            progressColor: AppColors.gold,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'المستوى ${_progress.level}',
                      style: GoogleFonts.cairo( 
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _progress.levelTitle,
                        style: GoogleFonts.cairo( 
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_progress.xp} / ${AppConstants.xpPerLevel} XP',
                  style: GoogleFonts.cairo( 
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: xpProgress,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
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

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.local_fire_department_rounded,
            '${_progress.streak}',
            'أيام متتالية',
            AppColors.streak,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            Icons.star_rounded,
            '${_progress.totalScore}',
            'إجمالي النقاط',
            AppColors.gold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            Icons.favorite_rounded,
            '${_progress.hearts}',
            'القلوب',
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
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
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Text(
            'الأداء العام',
            style: GoogleFonts.cairo( 
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  Icons.assignment_turned_in_rounded,
                  '${_progress.totalLessons}',
                  'تمرين مكتمل',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildMiniStat(
                  Icons.track_changes_rounded,
                  '${_progress.overallAccuracy.toInt()}%',
                  'الدقة الكلية',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildMiniStat(
                  Icons.bolt_rounded,
                  '${_progress.bestCombo}',
                  'أفضل كومبو',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 22),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo( 
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo( 
            fontSize: 9,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      _Achievement(Icons.eco_rounded, 'البداية', 'أكمل أول تمرين', _progress.totalLessons > 0, AppColors.primary),
      _Achievement(Icons.local_fire_department_rounded, 'متواصل', '3 أيام متتالية', _progress.streak >= 3, AppColors.streak),
      _Achievement(Icons.fitness_center_rounded, 'مثابر', '7 أيام متتالية', _progress.streak >= 7, AppColors.accent),
      _Achievement(Icons.bolt_rounded, 'كومبو ماستر', 'كومبو 5+', _progress.bestCombo >= 5, AppColors.secondary),
      _Achievement(Icons.calculate_rounded, 'حاسب بشري', '500 نقطة', _progress.totalScore >= 500, AppColors.purple),
      _Achievement(Icons.emoji_events_rounded, 'بطل الضرب', 'المستوى 5', _progress.level >= 5, AppColors.gold),
      _Achievement(Icons.star_rounded, 'نجم', '1000 نقطة', _progress.totalScore >= 1000, AppColors.gold),
      _Achievement(Icons.track_changes_rounded, 'قناص', 'كومبو 10+', _progress.bestCombo >= 10, AppColors.error),
      _Achievement(Icons.psychology_rounded, 'عبقري', 'المستوى 10', _progress.level >= 10, AppColors.secondary),
      _Achievement(Icons.workspace_premium_rounded, 'ملك الحساب', '5000 نقطة', _progress.totalScore >= 5000, AppColors.purple),
      _Achievement(Icons.auto_awesome_rounded, 'أسطوري', 'المستوى 20', _progress.level >= 20, AppColors.accent),
      _Achievement(Icons.diamond_rounded, 'الماسي', '10000 نقطة', _progress.totalScore >= 10000, AppColors.secondary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: achievement.unlocked
                ? AppColors.gold.withValues(alpha: 0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: achievement.unlocked
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: achievement.unlocked
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: achievement.unlocked
                      ? achievement.iconColor.withValues(alpha: 0.15)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 22,
                  color: achievement.unlocked ? achievement.iconColor : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.title,
                style: GoogleFonts.cairo( 
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: achievement.unlocked
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                achievement.description,
                style: GoogleFonts.cairo( 
                  fontSize: 9,
                  color: achievement.unlocked
                      ? AppColors.textSecondary
                      : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            .animate(delay: (60 * index).ms)
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
            );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(
              'إعادة تعيين',
              style: GoogleFonts.cairo( fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'سيتم حذف جميع بيانات التقدم. هل أنت متأكد؟',
          style: GoogleFonts.cairo( ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo( 
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.resetAll();
              await _loadProgress();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              'إعادة تعيين',
              style: GoogleFonts.cairo( 
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;
  final Color iconColor;

  _Achievement(this.icon, this.title, this.description, this.unlocked, this.iconColor);
}



