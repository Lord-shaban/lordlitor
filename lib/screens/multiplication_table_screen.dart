import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../services/question_generator.dart';
import '../widgets/duo_button.dart';
import 'quiz_screen.dart';

class MultiplicationTableScreen extends StatefulWidget {
  const MultiplicationTableScreen({super.key});

  @override
  State<MultiplicationTableScreen> createState() =>
      _MultiplicationTableScreenState();
}

class _MultiplicationTableScreenState
    extends State<MultiplicationTableScreen> {
  int? _selectedNumber;
  bool _showTable = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'جدول الضرب',
                  style: GoogleFonts.cairo( 
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.grid_on_rounded, size: 26, color: AppColors.accent),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 6),
            Text(
              'اختر رقم لدراسة جدول الضرب أو التدريب عليه',
              style: GoogleFonts.cairo( 
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // Number grid
            _buildNumberGrid(),

            if (_selectedNumber != null) ...[
              const SizedBox(height: 20),
              _buildToggleBar(),
              const SizedBox(height: 14),
              if (_showTable)
                _buildMultiplicationTable()
              else
                _buildPracticeSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        int number = index + 1;
        bool isSelected = _selectedNumber == number;
        Color tileColor = _getNumberColor(number);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedNumber = number;
              _showTable = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, isSelected ? 2 : 0, 0),
            decoration: BoxDecoration(
              color: isSelected ? tileColor : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? tileColor : const Color(0xFFE5E5E5),
                width: isSelected ? 2.5 : 2,
              ),
              boxShadow: isSelected
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.12),
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.cairo( 
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : tileColor,
                ),
              ),
            ),
          ),
        )
            .animate(delay: (25 * index).ms)
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
            );
      },
    );
  }

  Color _getNumberColor(int number) {
    List<Color> colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.purple,
      AppColors.error,
    ];
    return colors[(number - 1) % colors.length];
  }

  Widget _buildToggleBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTable = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showTable ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !_showTable
                      ? const Border(
                          bottom: BorderSide(
                            color: AppColors.primaryShadow,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'تدريب',
                    style: GoogleFonts.cairo( 
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: !_showTable
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTable = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showTable ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _showTable
                      ? const Border(
                          bottom: BorderSide(
                            color: AppColors.secondaryShadow,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'عرض الجدول',
                    style: GoogleFonts.cairo( 
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _showTable
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMultiplicationTable() {
    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 20,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey[100],
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          int multiplier = index + 1;
          int result = _selectedNumber! * multiplier;
          final numColor = _getNumberColor(_selectedNumber!);

          return Directionality(
            textDirection: TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: numColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$multiplier',
                        style: GoogleFonts.cairo( 
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: numColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_selectedNumber  ×  $multiplier',
                      style: GoogleFonts.cairo( 
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: numColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '=  $result',
                      style: GoogleFonts.cairo( 
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: numColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: (25 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.15, end: 0);
        },
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPracticeSection() {
    final color = _getNumberColor(_selectedNumber!);
    final shadowColor = AppColors.getShadow(color);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border(
          bottom: BorderSide(color: shadowColor, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.track_changes_rounded, size: 44, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            'تدريب على جدول $_selectedNumber',
            style: GoogleFonts.cairo( 
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '20 سؤال - الجدول كاملاً',
            style: GoogleFonts.cairo( 
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الأسئلة الخاطئة تُعاد حتى الإتقان الكامل',
            style: GoogleFonts.cairo( 
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          _DuoInvertButton(
            label: 'ابدأ التدريب',
            icon: Icons.play_arrow_rounded,
            onTap: _startTableTraining,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  void _startTableTraining() {
    final generator = QuestionGenerator();
    final questions = generator.generateFullMultiplicationTable(
      number: _selectedNumber!,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => QuizScreen(
          type: QuestionType.multiplication,
          difficulty: Difficulty.medium,
          categoryTitle: 'جدول $_selectedNumber',
          categoryColor: _getNumberColor(_selectedNumber!),
          categoryEmoji: 'table',
          customQuestions: questions,
          isTableMode: true,
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
  }
}

class _DuoInvertButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DuoInvertButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_DuoInvertButton> createState() => _DuoInvertButtonState();
}

class _DuoInvertButtonState extends State<_DuoInvertButton> {
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
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _pressed ? 0.35 : 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: GoogleFonts.cairo( 
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



