import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../models/question_model.dart';
import '../widgets/duo_button.dart';
import 'quiz_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

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
                  'التمارين',
                  style: GoogleFonts.cairo( 
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.school_rounded, size: 26, color: AppColors.secondary),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 6),
            Text(
              'اختر نوع التمرين وابدأ التدريب',
              style: GoogleFonts.cairo( 
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 24),

            // Categories list
            ..._buildCategoryCards(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryCards(BuildContext context) {
    final categories = [
      _CategoryData(
        title: 'الضرب',
        subtitle: 'تمارين جدول الضرب حتى 20×20',
        icon: Icons.close_rounded,
        color: AppColors.multiplicationColor,
        shadowColor: AppColors.multiplicationShadow,
        type: QuestionType.multiplication,
        categoryIcon: Icons.grid_on_rounded,
      ),
      _CategoryData(
        title: 'الجمع',
        subtitle: 'تمارين الجمع الذهني السريع',
        icon: Icons.add_rounded,
        color: AppColors.additionColor,
        shadowColor: AppColors.additionShadow,
        type: QuestionType.addition,
        categoryIcon: Icons.calculate_rounded,
      ),
      _CategoryData(
        title: 'الطرح',
        subtitle: 'تمارين الطرح بمختلف المستويات',
        icon: Icons.remove_rounded,
        color: AppColors.subtractionColor,
        shadowColor: AppColors.subtractionShadow,
        type: QuestionType.subtraction,
        categoryIcon: Icons.straighten_rounded,
      ),
      _CategoryData(
        title: 'القسمة',
        subtitle: 'تمارين القسمة والتحقق بالضرب',
        icon: Icons.percent_rounded,
        color: AppColors.divisionColor,
        shadowColor: AppColors.divisionShadow,
        type: QuestionType.division,
        categoryIcon: Icons.pie_chart_rounded,
      ),
      _CategoryData(
        title: 'حساب ذهني',
        subtitle: 'نسب مئوية، عمليات مركبة، وأكثر',
        icon: Icons.psychology_rounded,
        color: AppColors.mentalMathColor,
        shadowColor: AppColors.mentalMathShadow,
        type: QuestionType.mentalMath,
        categoryIcon: Icons.lightbulb_rounded,
      ),
    ];

    return categories.asMap().entries.map((entry) {
      int index = entry.key;
      var cat = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildCategoryCard(context, cat, index),
      );
    }).toList();
  }

  Widget _buildCategoryCard(
      BuildContext context, _CategoryData category, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDifficultyDialog(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon container with 3D effect
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    bottom: BorderSide(
                      color: category.color.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    category.categoryIcon,
                    size: 28,
                    color: category.color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: GoogleFonts.cairo( 
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle,
                      style: GoogleFonts.cairo( 
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Play button with 3D effect
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    bottom: BorderSide(
                      color: category.shadowColor,
                      width: 4,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.3, end: 0);
  }

  void _showDifficultyDialog(BuildContext context, _CategoryData category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Emoji in colored circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border(
                  bottom: BorderSide(
                    color: category.color.withValues(alpha: 0.25),
                    width: 4,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  category.categoryIcon,
                  size: 40,
                  color: category.color,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              category.title,
              style: GoogleFonts.cairo( 
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اختر مستوى الصعوبة',
              style: GoogleFonts.cairo( 
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Difficulty buttons - Duolingo style
            _buildDifficultyButton(
              context,
              'سهل',
              Icons.eco_rounded,
              'أرقام صغيرة - للمبتدئين',
              AppColors.primary,
              AppColors.primaryShadow,
              Difficulty.easy,
              category,
            ),
            const SizedBox(height: 12),
            _buildDifficultyButton(
              context,
              'متوسط',
              Icons.local_fire_department_rounded,
              'أرقام أكبر - تحدي معتدل',
              AppColors.accent,
              AppColors.accentDark,
              Difficulty.medium,
              category,
            ),
            const SizedBox(height: 12),
            _buildDifficultyButton(
              context,
              'صعب',
              Icons.bolt_rounded,
              'أرقام كبيرة - تحدي حقيقي!',
              AppColors.error,
              AppColors.errorDark,
              Difficulty.hard,
              category,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    IconData titleIcon,
    String subtitle,
    Color color,
    Color shadowColor,
    Difficulty difficulty,
    _CategoryData category,
  ) {
    return _DuoDifficultyButton(
      title: title,
      icon: titleIcon,
      subtitle: subtitle,
      color: color,
      shadowColor: shadowColor,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => QuizScreen(
              type: category.type,
              difficulty: difficulty,
              categoryTitle: category.title,
              categoryColor: category.color,
              categoryEmoji: 'cat',
            ),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}

class _DuoDifficultyButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final String subtitle;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _DuoDifficultyButton({
    required this.title,
    this.icon,
    required this.subtitle,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_DuoDifficultyButton> createState() => _DuoDifficultyButtonState();
}

class _DuoDifficultyButtonState extends State<_DuoDifficultyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.cairo( 
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.color,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.cairo( 
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.color, size: 22),
              const SizedBox(width: 6),
            ],
            Icon(Icons.arrow_back_ios_rounded,
                color: widget.color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final QuestionType type;
  final IconData categoryIcon;

  _CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.type,
    required this.categoryIcon,
  });
}



