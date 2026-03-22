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
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _loadProgress();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    await StorageService.updateStreak();
    final p = await StorageService.getUserProgress();
    if (mounted) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const CategoriesScreen(),
      const MultiplicationTableScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
    final active = _currentIndex == i;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _currentIndex = i); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : const Color(0xFFAFAFAF), size: active ? 27 : 23),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.cairo(fontSize: 10, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? AppColors.primary : const Color(0xFFAFAFAF))),
          ],
        ),
      ),
    );
  }

  // ==================== HOME TAB ====================
  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.15, end: 0),
              const SizedBox(height: 18),

              // Hero banner
              _buildHeroBanner().animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
              const SizedBox(height: 18),

              // Stats row
              _buildStatsRow().animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),
              const SizedBox(height: 22),

              // Quick practice title
              _sectionTitle('تدريب سريع', Icons.bolt_rounded, AppColors.accent)
                  .animate().fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 12),

              // Quick action grid
              _buildQuickGrid().animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 22),

              // XP Progress
              _buildXpCard().animate().fadeIn(duration: 400.ms, delay: 450.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 18),

              // Accuracy card
              _buildAccuracyCard().animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : (hour < 18 ? 'مساء الخير' : 'مساء الخير');
    final icon = hour < 12 ? Icons.wb_sunny_rounded : (hour < 18 ? Icons.wb_cloudy_rounded : Icons.nightlight_round);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(greeting, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(AppConstants.appName, style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  _levelBadge(),
                ],
              ),
            ],
          ),
        ),
        // Mascot avatar
        AnimatedBuilder(
          animation: _floatController,
          builder: (_, child) => Transform.translate(offset: Offset(0, _floatController.value * 5 - 2.5), child: child),
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('lib/image/logo_without_bg.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Lv.${_progress.level}',
        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }

  // ==================== HERO BANNER ====================
  Widget _buildHeroBanner() {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = 1); },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF58CC02), Color(0xFF46A302)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: const Border(bottom: BorderSide(color: Color(0xFF3B8C01), width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_progress.levelTitle} • Lv.${_progress.level}',
                      style: GoogleFonts.cairo(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivation(),
                    style: GoogleFonts.cairo(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // Start button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 3)),
                    ),
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
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _floatController,
              builder: (_, child) => Transform.translate(offset: Offset(0, _floatController.value * 8 - 4), child: child),
              child: Image.asset('lib/image/logo_happy.png', width: 85, height: 85),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivation() {
    if (_progress.streak > 7) return '🔥 ${_progress.streak} يوم متتالي! استمر!';
    if (_progress.streak > 3) return 'أداؤك رائع! واصل التقدم!';
    if (_progress.totalAnswered > 0) return 'أهلاً من جديد! هيا نتدرب!';
    return 'هيا نبدأ رحلة التعلم!';
  }

  // ==================== STATS ROW ====================
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statChip(Icons.local_fire_department_rounded, '${_progress.streak}', 'يوم', AppColors.streak)),
        const SizedBox(width: 8),
        Expanded(child: _statChip(Icons.star_rounded, '${_progress.xp}', 'XP', AppColors.gold)),
        const SizedBox(width: 8),
        Expanded(child: _statChip(Icons.check_circle_rounded, '${_progress.totalLessons}', 'درس', AppColors.primary)),
        const SizedBox(width: 8),
        Expanded(child: _statChip(Icons.emoji_events_rounded, '${_progress.bestCombo}', 'كومبو', AppColors.secondary)),
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
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: color), textDirection: TextDirection.ltr),
          Text(label, style: GoogleFonts.cairo(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }

  // ==================== QUICK GRID ====================
  Widget _buildQuickGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        _quickCard('الضرب', Icons.close_rounded, AppColors.multiplicationColor, () => _goCategory(QuestionType.multiplication)),
        _quickCard('الجمع', Icons.add_rounded, AppColors.additionColor, () => _goCategory(QuestionType.addition)),
        _quickCard('الطرح', Icons.remove_rounded, AppColors.subtractionColor, () => _goCategory(QuestionType.subtraction)),
        _quickCard('القسمة', Icons.percent_rounded, AppColors.divisionColor, () => _goCategory(QuestionType.division)),
        _quickCard('المتتاليات', Icons.trending_up_rounded, AppColors.sequenceColor, () => _goCategory(QuestionType.sequence)),
        _quickCard('ذهني', Icons.psychology_rounded, AppColors.mentalMathColor, () => _goCategory(QuestionType.mentalMath)),
      ],
    );
  }

  Widget _quickCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ==================== XP PROGRESS ====================
  Widget _buildXpCard() {
    final xpInLevel = _progress.xp % AppConstants.xpPerLevel;
    final progress = (xpInLevel / AppConstants.xpPerLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 4),
                  Text('المستوى التالي', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$xpInLevel / ${AppConstants.xpPerLevel} XP', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary), textDirection: TextDirection.ltr),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Stack(
                children: [
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1CB0F6), Color(0xFF49C4FF)]),
                        borderRadius: BorderRadius.circular(7),
                        border: const Border(bottom: BorderSide(color: Color(0xFF0095D9), width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACCURACY CARD ====================
  Widget _buildAccuracyCard() {
    final accuracy = _progress.overallAccuracy;
    final color = accuracy >= 80 ? AppColors.primary : (accuracy >= 50 ? AppColors.accent : AppColors.error);
    final emoji = accuracy >= 80 ? '🎯' : (accuracy >= 50 ? '💪' : '📈');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        children: [
          // Accuracy circle
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: (accuracy / 100).clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نسبة الإصابة', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('${accuracy.toStringAsFixed(1)}%', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900, color: color), textDirection: TextDirection.ltr),
                    const SizedBox(width: 8),
                    Text('${_progress.totalCorrect}/${_progress.totalAnswered} سؤال', style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600), textDirection: TextDirection.ltr),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goCategory(QuestionType type) {
    setState(() => _currentIndex = 1);
  }
}
