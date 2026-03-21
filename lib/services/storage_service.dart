import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/question_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static String _categoryKeyFromType(QuestionType type) {
    switch (type) {
      case QuestionType.multiplication:
        return AppConstants.keyMultiplicationProgress;
      case QuestionType.addition:
        return AppConstants.keyAdditionProgress;
      case QuestionType.subtraction:
        return AppConstants.keySubtractionProgress;
      case QuestionType.division:
        return AppConstants.keyDivisionProgress;
      case QuestionType.sequence:
        return AppConstants.keySequenceProgress;
      case QuestionType.mentalMath:
        return AppConstants.keyMentalMathProgress;
    }
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== User Progress ====================
  static Future<UserProgress> getUserProgress() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    return UserProgress(
      totalScore: _prefs!.getInt(AppConstants.keyTotalScore) ?? 0,
      streak: _prefs!.getInt(AppConstants.keyStreak) ?? 0,
      lastPlayDate: _prefs!.getString(AppConstants.keyLastPlayDate) != null
          ? DateTime.parse(_prefs!.getString(AppConstants.keyLastPlayDate)!)
          : null,
      level: _prefs!.getInt(AppConstants.keyLevel) ?? 1,
      xp: _prefs!.getInt(AppConstants.keyXp) ?? 0,
      hearts: _prefs!.getInt(AppConstants.keyHearts) ?? AppConstants.maxHearts,
      totalCorrect: _prefs!.getInt(AppConstants.keyTotalCorrect) ?? 0,
      totalAnswered: _prefs!.getInt(AppConstants.keyTotalAnswered) ?? 0,
      bestCombo: _prefs!.getInt(AppConstants.keyBestCombo) ?? 0,
      totalLessons: _prefs!.getInt(AppConstants.keyTotalLessons) ?? 0,
    );
  }

  static Future<void> saveUserProgress(UserProgress progress) async {
    _prefs ??= await SharedPreferences.getInstance();
    
    await _prefs!.setInt(AppConstants.keyTotalScore, progress.totalScore);
    await _prefs!.setInt(AppConstants.keyStreak, progress.streak);
    if (progress.lastPlayDate != null) {
      await _prefs!.setString(AppConstants.keyLastPlayDate, progress.lastPlayDate!.toIso8601String());
    }
    await _prefs!.setInt(AppConstants.keyLevel, progress.level);
    await _prefs!.setInt(AppConstants.keyXp, progress.xp);
    await _prefs!.setInt(AppConstants.keyHearts, progress.hearts);
  }

  // ==================== XP & Level ====================
  static Future<void> addXp(int xp) async {
    _prefs ??= await SharedPreferences.getInstance();
    
    int currentXp = _prefs!.getInt(AppConstants.keyXp) ?? 0;
    int currentLevel = _prefs!.getInt(AppConstants.keyLevel) ?? 1;
    
    currentXp += xp;
    
    // Level up check
    while (currentXp >= AppConstants.xpPerLevel) {
      currentXp -= AppConstants.xpPerLevel;
      currentLevel++;
    }
    
    await _prefs!.setInt(AppConstants.keyXp, currentXp);
    await _prefs!.setInt(AppConstants.keyLevel, currentLevel);
  }

  // ==================== Streak ====================
  static Future<int> updateStreak() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    String? lastDateStr = _prefs!.getString(AppConstants.keyLastPlayDate);
    int streak = _prefs!.getInt(AppConstants.keyStreak) ?? 0;
    DateTime now = DateTime.now();
    
    if (lastDateStr != null) {
      DateTime lastDate = DateTime.parse(lastDateStr);
      int daysDiff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;
      
      if (daysDiff == 1) {
        streak++;
      } else if (daysDiff > 1) {
        streak = 1;
      }
      // daysDiff == 0: already played today
    } else {
      streak = 1;
    }
    
    await _prefs!.setInt(AppConstants.keyStreak, streak);
    await _prefs!.setString(AppConstants.keyLastPlayDate, now.toIso8601String());
    
    return streak;
  }

  // ==================== Hearts ====================
  static Future<int> getHearts() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(AppConstants.keyHearts) ?? AppConstants.maxHearts;
  }

  static Future<void> loseHeart() async {
    _prefs ??= await SharedPreferences.getInstance();
    int hearts = _prefs!.getInt(AppConstants.keyHearts) ?? AppConstants.maxHearts;
    if (hearts > 0) hearts--;
    await _prefs!.setInt(AppConstants.keyHearts, hearts);
  }

  static Future<void> refillHearts() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(AppConstants.keyHearts, AppConstants.maxHearts);
  }

  // ==================== Category Progress ====================
  static Future<double> getCategoryProgress(String categoryKey) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getDouble(categoryKey) ?? 0.0;
  }

  static Future<void> updateCategoryProgress(String categoryKey, double progress) async {
    _prefs ??= await SharedPreferences.getInstance();
    double current = _prefs!.getDouble(categoryKey) ?? 0.0;
    double newProgress = (current + progress).clamp(0.0, 1.0);
    await _prefs!.setDouble(categoryKey, newProgress);
  }

  static Future<double> getCategoryMastery(QuestionType type) async {
    _prefs ??= await SharedPreferences.getInstance();
    final key = _categoryKeyFromType(type);
    return _prefs!.getDouble(key) ?? 0.0;
  }

  static Future<void> saveQuizPerformance({
    required QuestionType type,
    required Difficulty difficulty,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (totalQuestions <= 0) return;

    final key = _categoryKeyFromType(type);
    final current = _prefs!.getDouble(key) ?? 0.0;

    final accuracy = (correctAnswers / totalQuestions).clamp(0.0, 1.0);
    final difficultyWeight = switch (difficulty) {
      Difficulty.easy => 0.8,
      Difficulty.medium => 1.0,
      Difficulty.hard => 1.2,
    };

    final sessionScore = (accuracy * difficultyWeight).clamp(0.0, 1.0);
    final updated = current == 0 ? sessionScore : (current * 0.75) + (sessionScore * 0.25);

    await _prefs!.setDouble(key, updated.clamp(0.0, 1.0));
  }

  // ==================== Stats tracking ====================
  static Future<void> trackQuizCompletion({
    required int correctAnswers,
    required int totalQuestions,
    required int bestCombo,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    
    final prevCorrect = _prefs!.getInt(AppConstants.keyTotalCorrect) ?? 0;
    final prevAnswered = _prefs!.getInt(AppConstants.keyTotalAnswered) ?? 0;
    final prevBestCombo = _prefs!.getInt(AppConstants.keyBestCombo) ?? 0;
    final prevLessons = _prefs!.getInt(AppConstants.keyTotalLessons) ?? 0;
    
    await _prefs!.setInt(AppConstants.keyTotalCorrect, prevCorrect + correctAnswers);
    await _prefs!.setInt(AppConstants.keyTotalAnswered, prevAnswered + totalQuestions);
    await _prefs!.setInt(AppConstants.keyTotalLessons, prevLessons + 1);
    
    if (bestCombo > prevBestCombo) {
      await _prefs!.setInt(AppConstants.keyBestCombo, bestCombo);
    }
  }

  // ==================== Score ====================
  static Future<void> addScore(int score) async {
    _prefs ??= await SharedPreferences.getInstance();
    int current = _prefs!.getInt(AppConstants.keyTotalScore) ?? 0;
    await _prefs!.setInt(AppConstants.keyTotalScore, current + score);
  }

  // ==================== Reset ====================
  static Future<void> resetAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.clear();
  }
}
