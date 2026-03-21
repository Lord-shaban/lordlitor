enum QuestionType {
  multiplication,
  addition,
  subtraction,
  division,
  sequence,
  mentalMath,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class Question {
  final String questionText;
  final String correctAnswer;
  final QuestionType type;
  final Difficulty difficulty;
  final String? hint;
  final String? explanation;
  final int weight; // higher weight = harder/more rare question
  final int bonusXp; // extra XP for harder questions

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.type,
    required this.difficulty,
    this.hint,
    this.explanation,
    this.weight = 1,
    this.bonusXp = 0,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int xpEarned;
  final int bonusXpEarned;
  final int comboBonus;
  final int bestCombo;
  final Duration timeTaken;
  final QuestionType type;
  final Difficulty difficulty;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.xpEarned,
    this.bonusXpEarned = 0,
    this.comboBonus = 0,
    this.bestCombo = 0,
    required this.timeTaken,
    required this.type,
    this.difficulty = Difficulty.easy,
  });

  double get accuracy => totalQuestions > 0 
    ? (correctAnswers / totalQuestions) * 100 
    : 0;
    
  bool get isPerfect => correctAnswers == totalQuestions;
  
  int get totalXp => xpEarned + bonusXpEarned + comboBonus;
  
  String get grade {
    if (isPerfect) return 'S';
    if (accuracy >= 90) return 'A';
    if (accuracy >= 70) return 'B';
    if (accuracy >= 50) return 'C';
    return 'D';
  }

  int get stars {
    if (isPerfect) return 3;
    if (accuracy >= 70) return 2;
    if (accuracy >= 40) return 1;
    return 0;
  }
}

class UserProgress {
  int totalScore;
  int streak;
  DateTime? lastPlayDate;
  int level;
  int xp;
  int hearts;
  int totalCorrect;
  int totalAnswered;
  int bestCombo;
  int totalLessons;
  Map<String, int> completedLessons;
  Map<String, double> categoryProgress;

  UserProgress({
    this.totalScore = 0,
    this.streak = 0,
    this.lastPlayDate,
    this.level = 1,
    this.xp = 0,
    this.hearts = 5,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
    this.bestCombo = 0,
    this.totalLessons = 0,
    Map<String, int>? completedLessons,
    Map<String, double>? categoryProgress,
  }) : completedLessons = completedLessons ?? {},
       categoryProgress = categoryProgress ?? {};

  double get overallAccuracy => totalAnswered > 0 
      ? (totalCorrect / totalAnswered) * 100 
      : 0;

  String get levelTitle {
    if (level >= 50) return 'أسطوري';
    if (level >= 30) return 'خبير';
    if (level >= 20) return 'متقدم';
    if (level >= 10) return 'متوسط';
    if (level >= 5) return 'مبتدئ متقدم';
    return 'مبتدئ';
  }
}
