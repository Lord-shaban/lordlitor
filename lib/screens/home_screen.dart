import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';
import '../models/question_model.dart';
import 'categories_screen.dart';
import 'multiplication_table_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  UserProgress _progress = UserProgress();
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _loadProgress();
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  Future<void> _loadProgress() async {
    await StorageService.updateStreak();
    final p = await StorageService.getUserProgress();
    if (mounted) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [_buildHomeTab(), const CategoriesScreen(), const MultiplicationTableScreen(), const StatsScreen()][_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════ BOTTOM NAV ═══════════════════
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'الرئيسية'),
              _navItem(1, Icons.school_rounded, 'التمارين'),
              _navItem(2, Icons.grid_view_rounded, 'جدول الضرب'),
              _navItem(3, Icons.bar_chart_rounded, 'الإحصائيات'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final on = _currentIndex == i;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _currentIndex = i); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: on ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: on ? AppColors.primary : const Color(0xFFAFAFAF), size: on ? 26 : 22),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.cairo(fontSize: 10, fontWeight: on ? FontWeight.w800 : FontWeight.w500, color: on ? AppColors.primary : const Color(0xFFAFAFAF))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════ HOME TAB ═══════════════════
  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 16),
              _buildHeroBanner().animate().fadeIn(duration: 500.ms, delay: 80.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
              const SizedBox(height: 16),
              _buildStatsRow().animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _sectionTitle('تدريب سريع', Icons.bolt_rounded, AppColors.accent).animate().fadeIn(duration: 300.ms, delay: 240.ms),
              const SizedBox(height: 10),
              _buildCategoryCards().animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _buildProgressSection().animate().fadeIn(duration: 400.ms, delay: 380.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ HEADER ═══════════════════
  Widget _buildHeader() {
    final h = DateTime.now().hour;
    final greet = h < 12 ? 'صباح الخير ☀️' : (h < 18 ? 'مساء الخير 🌤️' : 'مساء الخير 🌙');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greet, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(AppConstants.appName, style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Lv.${_progress.level}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, child) => Transform.translate(offset: Offset(0, _floatCtrl.value * 5 - 2.5), child: child),
          child: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset('lib/image/logo_without_bg.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════ HERO BANNER ═══════════════════
  Widget _buildHeroBanner() {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = 1); },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF58CC02), Color(0xFF46A302)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: const Border(bottom: BorderSide(color: Color(0xFF3B8C01), width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('${_progress.levelTitle} • Lv.${_progress.level}', style: GoogleFonts.cairo(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Text(_motivation, style: GoogleFonts.cairo(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w800, height: 1.4)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: const Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 3))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Text('ابدأ التدريب', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, child) => Transform.translate(offset: Offset(0, _floatCtrl.value * 8 - 4), child: child),
              child: Image.asset('lib/image/logo_happy.png', width: 85, height: 85),
            ),
          ],
        ),
      ),
    );
  }

  String get _motivation {
    if (_progress.streak > 7) return '🔥 ${_progress.streak} يوم متتالي! استمر!';
    if (_progress.streak > 3) return 'أداؤك رائع! واصل التقدم!';
    if (_progress.totalAnswered > 0) return 'أهلاً من جديد! هيا نتدرب!';
    return 'هيا نبدأ رحلة التعلم!';
  }

  // ═══════════════════ STATS ROW ═══════════════════
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statChip(Icons.local_fire_department_rounded, '${_progress.streak}', 'يوم متتالي', AppColors.streak)),
        const SizedBox(width: 8),
        Expanded(child: _statChip(Icons.star_rounded, '${_progress.xp}', 'نقاط XP', AppColors.gold)),
        const SizedBox(width: 8),
        Expanded(child: _statChip(Icons.check_circle_rounded, '${_progress.totalLessons}', 'درس مكتمل', AppColors.primary)),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: color), textDirection: TextDirection.ltr),
          Text(label, style: GoogleFonts.cairo(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }

  // ═══════════════════ CATEGORY CARDS ═══════════════════
  Widget _buildCategoryCards() {
    return Column(
      children: [
        // Row 1: 3 cards
        Row(
          children: [
            Expanded(child: _catCard('الضرب', '✖️', Icons.close_rounded, AppColors.multiplicationColor, QuestionType.multiplication)),
            const SizedBox(width: 10),
            Expanded(child: _catCard('الجمع', '➕', Icons.add_rounded, AppColors.additionColor, QuestionType.addition)),
            const SizedBox(width: 10),
            Expanded(child: _catCard('الطرح', '➖', Icons.remove_rounded, AppColors.subtractionColor, QuestionType.subtraction)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: 2 wider cards
        Row(
          children: [
            Expanded(child: _catCardWide('القسمة', Icons.percent_rounded, AppColors.divisionColor, QuestionType.division)),
            const SizedBox(width: 10),
            Expanded(child: _catCardWide('حساب ذهني', Icons.psychology_rounded, AppColors.mentalMathColor, QuestionType.mentalMath)),
          ],
        ),
      ],
    );
  }

  Widget _catCard(String title, String emoji, IconData icon, Color color, QuestionType type) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = 1); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _catCardWide(String title, IconData icon, Color color, QuestionType type) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = 1); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════ PROGRESS SECTION ═══════════════════
  Widget _buildProgressSection() {
    final xpInLevel = _progress.xp % AppConstants.xpPerLevel;
    final xpProgress = (xpInLevel / AppConstants.xpPerLevel).clamp(0.0, 1.0);
    final accuracy = _progress.overallAccuracy;
    final accColor = accuracy >= 80 ? AppColors.primary : (accuracy >= 50 ? AppColors.accent : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        children: [
          // XP to next level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 4),
                  Text('المستوى ${_progress.level + 1}', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              Text('$xpInLevel / ${AppConstants.xpPerLevel} XP', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary), textDirection: TextDirection.ltr),
            ],
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 12,
              decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Stack(
                children: [
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    widthFactor: xpProgress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1CB0F6), Color(0xFF49C4FF)]),
                        borderRadius: BorderRadius.circular(6),
                        border: const Border(bottom: BorderSide(color: Color(0xFF0095D9), width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(height: 1, color: const Color(0xFFF0F0F0)),
          ),

          // Accuracy + questions + best combo
          Row(
            children: [
              // Accuracy
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 36, height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: (accuracy / 100).clamp(0.0, 1.0),
                              strokeWidth: 3.5,
                              backgroundColor: accColor.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(accColor),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text('🎯', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${accuracy.toStringAsFixed(0)}%', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900, color: accColor), textDirection: TextDirection.ltr),
                        Text('الدقة', style: GoogleFonts.cairo(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
              // Questions answered
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.quiz_rounded, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_progress.totalCorrect}/${_progress.totalAnswered}', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.secondary), textDirection: TextDirection.ltr),
                        Text('صح/مجموع', style: GoogleFonts.cairo(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
              // Best combo
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.streak, size: 18),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_progress.bestCombo}', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.streak), textDirection: TextDirection.ltr),
                        Text('كومبو', style: GoogleFonts.cairo(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
