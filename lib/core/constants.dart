class AppConstants {
  static const String appName = 'Lordlitor';
  static const String appTagline = 'تدريب القدرات الذهنية';
  
  // SharedPreferences keys
  static const String keyTotalScore = 'total_score';
  static const String keyStreak = 'streak';
  static const String keyLastPlayDate = 'last_play_date';
  static const String keyLevel = 'level';
  static const String keyXp = 'xp';
  static const String keyHearts = 'hearts';
  static const String keyCompletedLessons = 'completed_lessons';
  static const String keyMultiplicationProgress = 'multiplication_progress';
  static const String keyAdditionProgress = 'addition_progress';
  static const String keySubtractionProgress = 'subtraction_progress';
  static const String keyDivisionProgress = 'division_progress';
  static const String keyMentalMathProgress = 'mental_math_progress';
  static const String keyTotalCorrect = 'total_correct';
  static const String keyTotalAnswered = 'total_answered';
  static const String keyBestCombo = 'best_combo';
  static const String keyTotalLessons = 'total_lessons';
  
  // Game settings
  static const int maxHearts = 5;
  static const int xpPerCorrect = 10;
  static const int xpPerLesson = 50;
  static const int xpPerLevel = 200;
  static const int questionsPerLesson = 10;
  
  // Combo multipliers
  static const int comboThreshold3 = 3;
  static const int comboThreshold5 = 5;
  static const int comboThreshold8 = 8;
  static const double comboMultiplier3 = 1.5;
  static const double comboMultiplier5 = 2.0;
  static const double comboMultiplier8 = 3.0;
  
  // Multiplication table range
  static const int maxMultiplicationNumber = 20;
  
  // Difficulty weights  
  static const Map<String, List<int>> difficultyWeights = {
    'easy': [70, 25, 5],
    'medium': [20, 55, 25],
    'hard': [5, 30, 65],
  };
}
