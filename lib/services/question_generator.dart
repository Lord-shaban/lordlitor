import 'dart:math';
import '../models/question_model.dart';
import '../core/constants.dart';

class QuestionGenerator {
  final Random _random = Random();

  int _pickWeightedIndex(List<int> weights) {
    final total = weights.fold<int>(0, (sum, w) => sum + w);
    int roll = _random.nextInt(total);
    for (int i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) return i;
    }
    return weights.length - 1;
  }

  Question _createQuestionByType(QuestionType type, Difficulty difficulty) {
    switch (type) {
      case QuestionType.multiplication: return _createMultiplicationQuestion(difficulty);
      case QuestionType.addition: return _createAdditionQuestion(difficulty);
      case QuestionType.subtraction: return _createSubtractionQuestion(difficulty);
      case QuestionType.division: return _createDivisionQuestion(difficulty);
      case QuestionType.sequence: return _createSequenceQuestion(difficulty);
      case QuestionType.mentalMath: return _createMentalMathQuestion(difficulty);
    }
  }

  List<Difficulty> _buildDifficultyPlan({required Difficulty targetDifficulty, required double mastery, required int count}) {
    List<int> bw;
    switch (targetDifficulty) {
      case Difficulty.easy: bw = [90, 10, 0];    // 90% easy, 10% medium, 0% hard
      case Difficulty.medium: bw = [8, 85, 7];    // 85% medium
      case Difficulty.hard: bw = [0, 10, 90];     // 90% hard
    }
    // Mild adaptive adjustment based on mastery (much gentler now)
    if (mastery < 0.3) { bw[0] += 5; bw[2] = (bw[2] - 5).clamp(0, 100); }
    else if (mastery > 0.8) { bw[0] = (bw[0] - 5).clamp(0, 100); bw[2] += 5; }
    final plan = <Difficulty>[];
    for (int i = 0; i < count; i++) {
      plan.add(Difficulty.values[_pickWeightedIndex(bw)]);
    }
    return plan;
  }

  List<Question> generateAdaptiveQuestionsByType({required QuestionType type, required Difficulty targetDifficulty, required double mastery, int count = AppConstants.questionsPerLesson}) {
    final questions = <Question>[];
    final seen = <String>{};
    final plan = _buildDifficultyPlan(targetDifficulty: targetDifficulty, mastery: mastery.clamp(0.0, 1.0), count: count);
    for (int i = 0; i < plan.length; i++) {
      int att = 0;
      while (att < 15) {
        final q = _createQuestionByType(type, plan[i]);
        if (!seen.contains(q.questionText)) { seen.add(q.questionText); questions.add(q); break; }
        att++;
      }
      if (questions.length < i + 1) questions.add(_createQuestionByType(type, plan[i]));
    }
    return questions;
  }

  // ==================== MULTIPLICATION ====================
  // Exam analysis: 14×7, 16×18, 24×9, 32×23, 57×8, 66×22, 88×18, 122×12, 348×6
  // Key patterns: multiples of 11 (22,33,55,66,88), multiples of 5 (15,25,95,125,155)
  Question _createMultiplicationQuestion(Difficulty difficulty) {
    // Medium: 30% chance 2 ops, Hard: 40% chance 2 ops + 20% chance 3 ops
    final multiOpRoll = _random.nextInt(100);
    if (difficulty == Difficulty.medium && multiOpRoll < 30) return _mulMultiOp(difficulty, 2);
    if (difficulty == Difficulty.hard && multiOpRoll < 40) return _mulMultiOp(difficulty, 2);
    if (difficulty == Difficulty.hard && multiOpRoll >= 40 && multiOpRoll < 60) return _mulMultiOp(difficulty, 3);

    int a, b, weight, bonus; String? hint;
    switch (difficulty) {
      case Difficulty.easy:
        a = _random.nextInt(9) + 2; b = _random.nextInt(9) + 2;
        weight = 1; bonus = 0; hint = 'تذكّر جدول الضرب للعدد $a';
      case Difficulty.medium:
        final strategy = _random.nextInt(4);
        if (strategy == 0) {
          final hp = [[6,7],[6,8],[7,8],[7,9],[8,8],[8,9],[9,9],[7,12],[8,12],[9,12]];
          final p = hp[_random.nextInt(hp.length)]; a = p[0]; b = p[1];
        } else if (strategy == 1) {
          a = _random.nextInt(9) + 12; b = _random.nextInt(7) + 3;
        } else if (strategy == 2) {
          a = _random.nextInt(11) + 20; b = _random.nextInt(11) + 5;
        } else {
          a = [11,22,33][_random.nextInt(3)]; b = _random.nextInt(8) + 3;
        }
        weight = 2; bonus = 5; hint = 'قسّم $a إلى أجزاء أسهل ثم اضرب';
      case Difficulty.hard:
        final strategy = _random.nextInt(5);
        if (strategy == 0) { a = _random.nextInt(51) + 50; b = _random.nextInt(7) + 3; }
        else if (strategy == 1) { a = [44,55,66,77,88][_random.nextInt(5)]; b = _random.nextInt(21) + 8; }
        else if (strategy == 2) { a = _random.nextInt(101) + 100; b = _random.nextInt(10) + 3; }
        else if (strategy == 3) { a = _random.nextInt(301) + 200; b = _random.nextInt(4) + 3; }
        else { a = _random.nextInt(31) + 20; b = _random.nextInt(31) + 15; }
        weight = 4; bonus = 10; hint = 'قرّب $a لأقرب عدد سهل ثم اضبط';
    }
    if (_random.nextBool()) { final t = a; a = b; b = t; }
    return Question(questionText: '$a × $b = ؟', correctAnswer: '${a*b}', type: QuestionType.multiplication, difficulty: difficulty, weight: weight, bonusXp: bonus, hint: hint, explanation: '$a × $b = ${a*b}');
  }

  // Multi-op multiplication variants (Q9: 15×3+88, Q7: 14×7×3, Q6: 14×4÷2+18)
  Question _mulMultiOp(Difficulty d, int ops) {
    if (ops == 2) {
      final t = _random.nextInt(3);
      if (t == 0) {
        // a × b + c (like Q9: 15×3+88)
        final a = _r(_rng(d,[5,15],[12,30],[30,125])), b = _r(_rng(d,[2,6],[3,9],[3,8])), c = _r(_rng(d,[10,50],[30,150],[50,400]));
        final ans = a*b+c;
        return Question(questionText:'$a × $b + $c = ؟',correctAnswer:'$ans',type:QuestionType.multiplication,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a × $b = ${a*b} ثم + $c',explanation:'${a*b} + $c = $ans');
      } else if (t == 1) {
        // a × b × c (like Q7: 14×7×3)
        final a = _r(_rng(d,[2,8],[7,20],[14,50])), b = _r(_rng(d,[2,5],[3,9],[3,12])), c = _r(_rng(d,[2,3],[2,4],[2,5]));
        final ans = a*b*c;
        return Question(questionText:'$a × $b × $c = ؟',correctAnswer:'$ans',type:QuestionType.multiplication,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a × $b = ${a*b} ثم × $c',explanation:'${a*b} × $c = $ans');
      } else {
        // a × b ÷ c (like Q6: 14×4÷2)
        final c = _r(_rng(d,[2,3],[2,5],[3,8])), q = _r(_rng(d,[4,15],[10,40],[20,100]));
        final ab = q*c; final a = _findFactor(ab); final b = ab~/a;
        if (b < 2) return _createMultiplicationQuestion(d);
        return Question(questionText:'$a × $b ÷ $c = ؟',correctAnswer:'$q',type:QuestionType.multiplication,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a × $b = $ab ثم ÷ $c',explanation:'$ab ÷ $c = $q');
      }
    }
    // 3 ops: a × b + c × d (like Q2: 9×6+12×4) or a × b ÷ c + d
    final t = _random.nextInt(2);
    if (t == 0) {
      final a=_r(_rng(d,[3,12],[9,25],[20,88])),b=_r(_rng(d,[2,6],[3,8],[3,9])),c=_r(_rng(d,[3,12],[12,30],[30,200])),dd=_r(_rng(d,[2,5],[3,7],[3,8]));
      final ans=a*b+c*dd;
      return Question(questionText:'$a × $b + $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.multiplication,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+2,hint:'($a×$b) + ($c×$dd)',explanation:'${a*b} + ${c*dd} = $ans');
    } else {
      final c=_r(_rng(d,[2,4],[3,6],[4,8])),q=_r(_rng(d,[4,15],[10,50],[20,120]));
      final ab=q*c; final a=_findFactor(ab); final b=ab~/a;
      if(b<2) return _createMultiplicationQuestion(d);
      final dd=_r(_rng(d,[5,30],[20,100],[50,300])); final ans=q+dd;
      return Question(questionText:'$a × $b ÷ $c + $dd = ؟',correctAnswer:'$ans',type:QuestionType.multiplication,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+2,hint:'$a×$b=$ab، ÷$c=$q، +$dd',explanation:'$q + $dd = $ans');
    }
  }

  // ==================== ADDITION ====================
  // Exam adds: +66, +88, +147, +148, +149, +160, +177, +196, +244, +322, +459, +655, +987
  // Pattern: non-round "tricky" numbers that look hard but have patterns
  Question _createAdditionQuestion(Difficulty difficulty) {
    // Medium: 25% three-term, Hard: 30% three-term + 15% with multiply
    final roll = _random.nextInt(100);
    if (difficulty == Difficulty.medium && roll < 25) return _addMultiOp(difficulty);
    if (difficulty == Difficulty.hard && roll < 45) return _addMultiOp(difficulty);

    int a, b, weight, bonus; String? hint;
    switch (difficulty) {
      case Difficulty.easy:
        a = _random.nextInt(40) + 10; b = _random.nextInt(40) + 10;
        weight = 1; bonus = 0; hint = 'جمّع العشرات ثم الآحاد';
      case Difficulty.medium:
        final strategy = _random.nextInt(3);
        if (strategy == 0) { a = (_random.nextInt(15)+3)*10+_random.nextInt(5); b = _random.nextInt(120)+40; }
        else if (strategy == 1) { a = [33,44,55,66,77,88,99,110,120,144,155][_random.nextInt(11)]; b = _random.nextInt(150)+30; }
        else { a = _random.nextInt(200)+50; b = _random.nextInt(200)+50; }
        weight = 2; bonus = 3;
        final roundA = ((a/10).round())*10;
        hint = 'قرّب $a ≈ $roundA ثم اضبط ${a-roundA}';
      case Difficulty.hard:
        final strategy = _random.nextInt(3);
        if (strategy == 0) { a = _random.nextInt(700)+200; b = _random.nextInt(700)+200; }
        else if (strategy == 1) { a = _random.nextInt(500)+150; b = _random.nextInt(500)+150; }
        else { a = _random.nextInt(4000)+500; b = _random.nextInt(1000)+100; }
        weight = 4; bonus = 8;
        final roundA = ((a/100).round())*100;
        hint = 'قرّب: $roundA + $b = ${roundA+b}، ±${a-roundA}';
    }
    return Question(questionText: '$a + $b = ؟', correctAnswer: '${a+b}', type: QuestionType.addition, difficulty: difficulty, weight: weight, bonusXp: bonus, hint: hint, explanation: '$a + $b = ${a+b}');
  }

  // Multi-op addition: a+b+c, a+b×c (Q26: 66+55×3=231, Q50: 255+371+174÷6)
  Question _addMultiOp(Difficulty d) {
    final t = _random.nextInt(d == Difficulty.hard ? 3 : 2);
    if (t == 0) {
      // a + b + c (3-term addition)
      final a=_r(_rng(d,[10,40],[50,200],[100,500])),b=_r(_rng(d,[10,40],[50,200],[100,500])),c=_r(_rng(d,[5,30],[20,100],[50,300]));
      final ans=a+b+c;
      return Question(questionText:'$a + $b + $c = ؟',correctAnswer:'$ans',type:QuestionType.addition,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'اجمع الأولين ثم أضف الثالث',explanation:'${a+b} + $c = $ans');
    } else if (t == 1) {
      // a + b × c (like Q26: 66+55×3=231)
      final a=_r(_rng(d,[10,30],[20,100],[29,300])),b=_r(_rng(d,[5,15],[15,55],[40,200])),c=_r(_rng(d,[2,4],[3,5],[3,9]));
      final ans=a+b*c;
      return Question(questionText:'$a + $b × $c = ؟',correctAnswer:'$ans',type:QuestionType.addition,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+2,hint:'الضرب أولاً: $b×$c=${b*c}، ثم +$a',explanation:'$a + ${b*c} = $ans');
    } else {
      // a + b + c ÷ d (like Q50: 255+371+174÷6)
      final a=_r(_rng(d,[50,200],[100,400],[200,955])),b=_r(_rng(d,[30,100],[100,400],[200,600])),dd=_r(_rng(d,[2,4],[3,6],[4,8])),cq=_r(_rng(d,[5,20],[15,50],[20,100]));
      final c=cq*dd; final ans=a+b+cq;
      return Question(questionText:'$a + $b + $c ÷ $dd = ؟',correctAnswer:'$ans',type:QuestionType.addition,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+3,hint:'القسمة أولاً: $c÷$dd=$cq',explanation:'$a + $b + $cq = $ans');
    }
  }

  // ==================== SUBTRACTION ====================
  // Exam: 955-616, 6060-4576, 1594-1090, results often non-round
  Question _createSubtractionQuestion(Difficulty difficulty) {
    // Hard: 35% multi-op subtraction
    if (difficulty == Difficulty.hard && _random.nextInt(100) < 35) return _subMultiOp(difficulty);

    int a, b, weight, bonus; String? hint;
    switch (difficulty) {
      case Difficulty.easy:
        a = _random.nextInt(50) + 20; b = _random.nextInt(15) + 3;
        weight = 1; bonus = 0; hint = 'اطرح العشرات ثم الآحاد';
      case Difficulty.medium:
        final strategy = _random.nextInt(2);
        if (strategy == 0) { a = _random.nextInt(400)+150; b = _random.nextInt(150)+30; }
        else { a = [155,177,244,270,311,326,349,415][_random.nextInt(8)]; b = _random.nextInt(100)+30; }
        weight = 2; bonus = 3; hint = 'قرّب المطروح لأقرب عشرة ثم اضبط';
      case Difficulty.hard:
        final strategy = _random.nextInt(3);
        if (strategy == 0) { a = _random.nextInt(600)+400; b = _random.nextInt(350)+100; }
        else if (strategy == 1) { a = _random.nextInt(2000)+800; b = _random.nextInt(800)+200; }
        else { a = _random.nextInt(5000)+2000; b = _random.nextInt(2000)+500; }
        weight = 4; bonus = 8;
        final roundB = ((b/100).round())*100;
        hint = 'اطرح $roundB أولاً: ${a-roundB}، ثم ±${roundB-b}';
    }
    if (a < b) { final t = a; a = b; b = t; }
    return Question(questionText: '$a - $b = ؟', correctAnswer: '${a-b}', type: QuestionType.subtraction, difficulty: difficulty, weight: weight, bonusXp: bonus, hint: hint, explanation: '$a - $b = ${a-b}');
  }

  // Multi-op subtraction: a-b-c, a-b×c+d (like Q66-68: 955-133×6+459=616)
  Question _subMultiOp(Difficulty d) {
    final t = _random.nextInt(2);
    if (t == 0) {
      // a - b - c
      final b=_r(_rng(d,[10,50],[50,200],[100,500])),c=_r(_rng(d,[5,30],[30,150],[50,400]));
      final a=b+c+_r(_rng(d,[10,50],[50,300],[100,1000]));
      final ans=a-b-c;
      return Question(questionText:'$a - $b - $c = ؟',correctAnswer:'$ans',type:QuestionType.subtraction,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+2,hint:'$a - $b = ${a-b}، ثم - $c',explanation:'${a-b} - $c = $ans');
    } else {
      // a - b × c + d (like Q66: 955-133×6+459=616)
      final b=_r(_rng(d,[10,30],[50,150],[100,233])),c=_r(_rng(d,[2,4],[3,5],[3,6])),dd=_r(_rng(d,[5,20],[30,150],[50,459]));
      final bc=b*c; final a=bc+dd+_r(_rng(d,[10,40],[50,200],[100,800]));
      final ans=a-bc+dd;
      if(ans<0) return _createSubtractionQuestion(d);
      return Question(questionText:'$a - $b × $c + $dd = ؟',correctAnswer:'$ans',type:QuestionType.subtraction,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+3,hint:'الضرب أولاً: $b×$c=$bc',explanation:'$a - $bc + $dd = ${a-bc} + $dd = $ans');
    }
  }

  // ==================== DIVISION ====================
  // Exam divisors: 2,3,4,5,6,7,8,9,10,15,22,63
  // Exam dividends: 80,90,126,130,165,174,180,208,250,252,266,485,528,645,658,666,762,880,945
  // Key: division ALWAYS produces clean integers, ÷5 is very common
  Question _createDivisionQuestion(Difficulty difficulty) {
    // Medium: 25% multi-op, Hard: 40% multi-op
    if (difficulty == Difficulty.medium && _random.nextInt(100) < 25) return _divMultiOp(difficulty);
    if (difficulty == Difficulty.hard && _random.nextInt(100) < 40) return _divMultiOp(difficulty);

    int divisor, quotient, weight, bonus; String? hint;
    switch (difficulty) {
      case Difficulty.easy:
        divisor = _random.nextInt(5) + 2; quotient = _random.nextInt(10) + 2;
        weight = 1; bonus = 0;
      case Difficulty.medium:
        final strategy = _random.nextInt(3);
        if (strategy == 0) { divisor = _random.nextBool() ? 5 : 10; quotient = _random.nextInt(30)+10; }
        else if (strategy == 1) { divisor = _random.nextInt(4)+6; quotient = _random.nextInt(20)+5; }
        else { divisor = [12,15][_random.nextInt(2)]; quotient = _random.nextInt(15)+5; }
        weight = 2; bonus = 5;
      case Difficulty.hard:
        final strategy = _random.nextInt(4);
        if (strategy == 0) { divisor = 5; quotient = _random.nextInt(150)+50; }
        else if (strategy == 1) { divisor = _random.nextInt(3)+6; quotient = _random.nextInt(100)+30; }
        else if (strategy == 2) { divisor = [22,33,44,63][_random.nextInt(4)]; quotient = _random.nextInt(15)+3; }
        else { divisor = [3,4,9][_random.nextInt(3)]; quotient = _random.nextInt(200)+50; }
        weight = 4; bonus = 10;
    }
    int dividend = divisor * quotient;
    hint = 'ما العدد الذي إذا ضربته في $divisor يعطي $dividend؟';
    return Question(questionText: '$dividend ÷ $divisor = ؟', correctAnswer: '$quotient', type: QuestionType.division, difficulty: difficulty, weight: weight, bonusXp: bonus, hint: hint, explanation: '$dividend ÷ $divisor = $quotient\nلأن $divisor × $quotient = $dividend');
  }

  // Multi-op division: a÷b+c, a÷b×c, a÷b÷c×d (Q45,Q48,Q64)
  Question _divMultiOp(Difficulty d) {
    final t = _random.nextInt(d == Difficulty.hard ? 3 : 2);
    if (t == 0) {
      // a ÷ b + c (divide then add)
      final b=_r(_rng(d,[2,5],[5,8],[5,10])),q=_r(_rng(d,[3,15],[10,40],[50,150]));
      final a=q*b; final c=_r(_rng(d,[5,30],[20,100],[50,300])); final ans=q+c;
      return Question(questionText:'$a ÷ $b + $c = ؟',correctAnswer:'$ans',type:QuestionType.division,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a ÷ $b = $q ثم + $c',explanation:'$q + $c = $ans');
    } else if (t == 1) {
      // a ÷ b × c (like Q45: 165÷15×12=132, Q48: 252÷63×9)
      final b=_r(_rng(d,[2,5],[5,15],[7,63])),q=_r(_rng(d,[3,10],[8,25],[4,100]));
      final a=q*b; final c=_r(_rng(d,[2,5],[5,12],[6,20])); final ans=q*c;
      return Question(questionText:'$a ÷ $b × $c = ؟',correctAnswer:'$ans',type:QuestionType.division,difficulty:d,weight:_wt(d)+1,bonusXp:_bxp(d)+2,hint:'$a ÷ $b = $q ثم × $c',explanation:'$q × $c = $ans');
    } else {
      // a ÷ b ÷ c × d (like Q64: 945÷5÷3×12=756)
      final b=_r(_rng(d,[2,3],[3,5],[3,7])),c=_r(_rng(d,[2,3],[3,5],[3,5]));
      final q2=_r(_rng(d,[3,10],[10,30],[30,100])); final q1=q2*c; final a=q1*b;
      final dd=_r(_rng(d,[2,5],[5,12],[6,20])); final ans=q2*dd;
      return Question(questionText:'$a ÷ $b ÷ $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.division,difficulty:d,weight:_wt(d)+2,bonusXp:_bxp(d)+4,hint:'$a÷$b=$q1، $q1÷$c=$q2، ×$dd',explanation:'$q2 × $dd = $ans');
    }
  }

  // ==================== SEQUENCES ====================
  Question _createSequenceQuestion(Difficulty difficulty) {
    final t = _pickWeightedIndex(difficulty == Difficulty.easy ? [55,5,25,15] : (difficulty == Difficulty.medium ? [25,25,20,30] : [10,35,15,40]));
    switch (t) { case 0: return _arithmeticSeq(difficulty); case 1: return _multiplySeq(difficulty); case 2: return _squareSeq(difficulty); default: return _incAddSeq(difficulty); }
  }
  Question _arithmeticSeq(Difficulty d) {
    int s, df; switch(d) { case Difficulty.easy: s=_random.nextInt(5)+1; df=_random.nextInt(3)+2; case Difficulty.medium: s=_random.nextInt(10)+1; df=_random.nextInt(6)+3; case Difficulty.hard: s=_random.nextInt(20)+5; df=_random.nextInt(10)+5; }
    List<int> seq = [for(int i=0;i<5;i++) s+df*i]; int ans = s+df*5;
    return Question(questionText: 'أكمل السلسلة:\n${seq.join(" ,  ")} ,  ؟', correctAnswer: '$ans', type: QuestionType.sequence, difficulty: d, weight: _wt(d), bonusXp: _bxp(d), hint: 'الفرق = +$df', explanation: 'الفرق الثابت = $df، التالي = ${seq.last} + $df = $ans');
  }
  Question _multiplySeq(Difficulty d) {
    int s, m; switch(d) { case Difficulty.easy: s=_random.nextInt(2)+1; m=2; case Difficulty.medium: s=_random.nextInt(3)+1; m=3; case Difficulty.hard: s=_random.nextInt(3)+1; m=_random.nextInt(2)+2; }
    List<int> seq = []; int v = s; for(int i=0;i<4;i++){seq.add(v);v*=m;} int ans = v;
    return Question(questionText: 'أكمل السلسلة:\n${seq.join(" ,  ")} ,  ؟', correctAnswer: '$ans', type: QuestionType.sequence, difficulty: d, weight: _wt(d), bonusXp: _bxp(d), hint: 'كل عدد × $m', explanation: '${seq.last} × $m = $ans');
  }
  Question _squareSeq(Difficulty d) {
    int sn; switch(d) { case Difficulty.easy: sn=1; case Difficulty.medium: sn=_random.nextInt(3)+2; case Difficulty.hard: sn=_random.nextInt(5)+4; }
    List<int> seq = [for(int i=0;i<5;i++) (sn+i)*(sn+i)]; int ans = (sn+5)*(sn+5);
    return Question(questionText: 'أكمل السلسلة:\n${seq.join(" ,  ")} ,  ؟', correctAnswer: '$ans', type: QuestionType.sequence, difficulty: d, weight: _wt(d), bonusXp: _bxp(d), hint: 'مربعات أعداد متتالية', explanation: '${sn+5}² = $ans');
  }
  Question _incAddSeq(Difficulty d) {
    int s, ad; switch(d) { case Difficulty.easy: s=_random.nextInt(3)+1; ad=1; case Difficulty.medium: s=_random.nextInt(5)+2; ad=2; case Difficulty.hard: s=_random.nextInt(10)+5; ad=_random.nextInt(3)+2; }
    List<int> seq = [s]; int a = ad; for(int i=1;i<5;i++){seq.add(seq.last+a);a+=ad;} int ans = seq.last+a;
    return Question(questionText: 'أكمل السلسلة:\n${seq.join(" ,  ")} ,  ؟', correctAnswer: '$ans', type: QuestionType.sequence, difficulty: d, weight: _wt(d), bonusXp: _bxp(d), hint: 'الفرق يزداد بمقدار $ad', explanation: 'التالي = ${seq.last} + $a = $ans');
  }

  int _wt(Difficulty d) => d == Difficulty.hard ? 4 : (d == Difficulty.medium ? 2 : 1);
  int _bxp(Difficulty d) => d == Difficulty.hard ? 10 : (d == Difficulty.medium ? 5 : 0);
  int _r(List<int> r) => _random.nextInt(r[1] - r[0] + 1) + r[0];
  List<int> _rng(Difficulty d, List<int> e, List<int> m, List<int> h) => switch(d) { Difficulty.easy => e, Difficulty.medium => m, Difficulty.hard => h };

  int _findFactor(int n) { List<int> f = []; for(int i=2;i<=n~/2;i++) if(n%i==0) f.add(i); return f.isEmpty ? n : f[_random.nextInt(f.length)]; }

  // ==================== MENTAL MATH (Comprehensive) ====================
  Question _createMentalMathQuestion(Difficulty difficulty) {
    final t = _pickWeightedIndex(difficulty == Difficulty.easy
      ? [25,15,15,10,10,10,5,10,0]
      : (difficulty == Difficulty.medium ? [35,10,8,12,10,5,8,7,5] : [40,8,5,12,12,3,5,5,10]));
    switch(t) {
      case 0: return _multiOpQ(difficulty);
      case 1: return _fractionWordQ(difficulty);
      case 2: return _timeConvQ(difficulty);
      case 3: return _percentQ(difficulty);
      case 4: return _missingNumQ(difficulty);
      case 5: return _doubleHalfQ(difficulty);
      case 6: return _geometryQ(difficulty);
      case 7: return _directMulQ(difficulty);
      default: return _calendarQ(difficulty);
    }
  }

  // --- Multi-Operation (like exam questions, PEMDAS) ---
  Question _multiOpQ(Difficulty d) {
    // Easy: 7 simple patterns, Medium: 15, Hard: all 21
    final p = _random.nextInt(d == Difficulty.easy ? 7 : (d == Difficulty.medium ? 15 : 21));
    switch(p) {
      case 0: return _p_axb_c(d);      case 1: return _p_axbxc(d);
      case 2: return _p_axb_cxd(d);    case 3: return _p_axb_m_cxd(d);
      case 4: return _p_axbd_c(d);     case 5: return _p_axb_cd(d);
      case 6: return _p_axbdxc(d);     case 7: return _p_axbxcd(d);
      case 8: return _p_a_bxcxd(d);    case 9: return _p_adb_xc_d(d);
      case 10: return _p_adb_xc(d);    case 11: return _p_a_m_bxc_d(d);
      case 12: return _p_a_b_cd(d);    case 13: return _p_axbd_cxe(d);
      case 14: return _p_axbd_m_c(d);  case 15: return _p_adb_xc_m_d(d);
      case 16: return _p_a_bdxc(d);    case 17: return _p_adb_cxd(d);
      case 18: return _p_axbxc_m_d(d); case 19: return _p_adbd_xc(d);
      default: return _p_a_m_bxc_m_d(d);
    }
  }

  // a × b + c  (Easy:Q9 15×3+88=133, Med:Q25 60×20+160=1360, Hard:Q40 125×8+126÷6)
  Question _p_axb_c(Difficulty d) {
    final a=_r(_rng(d,[2,15],[15,66],[60,155])), b=_r(_rng(d,[2,8],[3,20],[5,30])), c=_r(_rng(d,[5,50],[50,200],[100,700]));
    final ans = a*b+c;
    return Question(questionText:'$a × $b + $c = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'احسب $a × $b أولاً ثم أضف $c',explanation:'$a × $b + $c = ${a*b} + $c = $ans');
  }
  // a × b × c  (Easy:Q1 3×3×8=72, Med:Q7 14×7×3=294, Hard:Q20 32×23×3=2208)
  Question _p_axbxc(Difficulty d) {
    final a=_r(_rng(d,[2,8],[7,20],[15,112])), b=_r(_rng(d,[2,5],[3,10],[3,23])), c=_r(_rng(d,[2,4],[2,5],[2,6]));
    final ans = a*b*c;
    return Question(questionText:'$a × $b × $c = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a × $b = ${a*b} ثم × $c',explanation:'$a × $b × $c = ${a*b} × $c = $ans');
  }
  // a × b + c × d  (Med:Q2 9×6+12×4=102, Hard:Q23 52×3+62×8=652)
  Question _p_axb_cxd(Difficulty d) {
    final a=_r(_rng(d,[2,10],[9,25],[37,355])), b=_r(_rng(d,[2,5],[3,8],[3,8])), c=_r(_rng(d,[2,10],[12,20],[55,448])), dd=_r(_rng(d,[2,4],[3,7],[3,9]));
    final ans = a*b+c*dd;
    return Question(questionText:'$a × $b + $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'($a×$b) + ($c×$dd)',explanation:'${a*b} + ${c*dd} = $ans');
  }
  // a × b - c × d  (Med:Q15 20×15-17×7=181, Hard:Q18 25×30-50×8=350)
  Question _p_axb_m_cxd(Difficulty d) {
    int a,b,c,dd; do { a=_r(_rng(d,[5,15],[20,30],[25,88])); b=_r(_rng(d,[3,8],[8,18],[8,30])); c=_r(_rng(d,[2,8],[5,17],[17,66])); dd=_r(_rng(d,[2,5],[5,8],[6,10])); } while(a*b<=c*dd);
    final ans = a*b-c*dd;
    return Question(questionText:'$a × $b - $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'($a×$b) - ($c×$dd)',explanation:'${a*b} - ${c*dd} = $ans');
  }
  // a × b ÷ c + d  (Easy:Q6 14×4÷2+18=46, Med:Q39 122×12÷8+148=331, Hard:Q29 74×9÷6+987=1098)
  Question _p_axbd_c(Difficulty d) {
    final c=_r(_rng(d,[2,4],[4,8],[5,10])), q=_r(_rng(d,[4,20],[15,80],[50,200]));
    final ab=q*c; final a=_findFactor(ab); final b=ab~/a;
    if(b<2) return _p_axb_c(d);
    final dd=_r(_rng(d,[5,30],[50,200],[100,987])); final ans=q+dd;
    return Question(questionText:'$a × $b ÷ $c + $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a×$b=$ab، $ab÷$c=$q، +$dd',explanation:'$a × $b ÷ $c + $dd = $q + $dd = $ans');
  }
  // a × b + c ÷ d  (Med:Q5 12×16+180÷6=222, Hard:Q32 88×18+80÷8=1594)
  Question _p_axb_cd(Difficulty d) {
    final a=_r(_rng(d,[3,12],[12,20],[16,125])), b=_r(_rng(d,[2,6],[8,18],[8,18])), dd=_r(_rng(d,[2,4],[5,8],[5,10])), cq=_r(_rng(d,[3,12],[20,40],[10,130]));
    final c=cq*dd; final ans=a*b+cq;
    return Question(questionText:'$a × $b + $c ÷ $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'($a×$b) + ($c÷$dd)',explanation:'${a*b} + $cq = $ans');
  }
  // a × b ÷ c × d  (Med:Q8 14×14÷7×19=532, Hard:Q58 570×6÷9×2=760)
  Question _p_axbdxc(Difficulty d) {
    final c=_r(_rng(d,[2,4],[5,9],[6,22])), s=_r(_rng(d,[3,12],[14,50],[50,200]));
    final ab=s*c; final a=_findFactor(ab); final b=ab~/a;
    if(b<2) return _p_axbxc(d);
    final dd=_r(_rng(d,[2,6],[6,19],[2,19])); final ans=s*dd;
    return Question(questionText:'$a × $b ÷ $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a×$b=$ab، ÷$c=$s، ×$dd',explanation:'$ab ÷ $c × $dd = $s × $dd = $ans');
  }
  // a × b × c ÷ d  (Med:Q10 15×8×4÷5=96, Hard:Q38 122×6×5÷15=244)
  Question _p_axbxcd(Difficulty d) {
    final dd=_r(_rng(d,[2,3],[3,6],[5,15])), q=_r(_rng(d,[8,30],[40,120],[96,400]));
    final prod=q*dd; final a=_r(_rng(d,[2,8],[10,25],[15,122]));
    if(prod%a!=0||prod~/a<2) return _p_axbxc(d);
    final rem=prod~/a; final b2=_findFactor(rem); final c=rem~/b2;
    if(c<2) return _p_axbxc(d);
    return Question(questionText:'$a × $b2 × $c ÷ $dd = ؟',correctAnswer:'$q',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'اضرب أولاً ثم اقسم',explanation:'$a × $b2 × $c ÷ $dd = $prod ÷ $dd = $q');
  }
  // a + b × c × d  (Med:Q11 15+17×2×3=117, Hard:Q34 102+3×6×9=264)
  Question _p_a_bxcxd(Difficulty d) {
    final a=_r(_rng(d,[5,18],[15,30],[29,144])), b=_r(_rng(d,[2,8],[5,17],[3,48])), c=_r(_rng(d,[2,3],[2,5],[2,6])), dd=_r(_rng(d,[2,3],[2,4],[3,9]));
    final ans=a+b*c*dd;
    return Question(questionText:'$a + $b × $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'الضرب أولاً: $b×$c×$dd=${b*c*dd}',explanation:'$a + ${b*c*dd} = $ans');
  }
  // a ÷ b × c + d  (Med:Q33 95÷5×9+244=415, Hard:Q46 208÷8×7+322=504)
  Question _p_adb_xc_d(Difficulty d) {
    final b=_r(_rng(d,[2,4],[5,8],[5,10])), q=_r(_rng(d,[4,12],[11,30],[26,100]));
    final a=q*b; final c=_r(_rng(d,[2,6],[5,12],[6,12])), dd=_r(_rng(d,[10,40],[100,322],[144,987]));
    final ans=q*c+dd;
    return Question(questionText:'$a ÷ $b × $c + $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a÷$b=$q، ×$c=${q*c}، +$dd',explanation:'$q × $c + $dd = ${q*c} + $dd = $ans');
  }
  // a ÷ b × c  (Med:Q45 165÷15×12=132, Hard:Q48 252÷63×9=36)
  Question _p_adb_xc(Difficulty d) {
    final b=_r(_rng(d,[2,5],[5,15],[7,63])), q=_r(_rng(d,[3,10],[8,25],[4,100]));
    final a=q*b; final c=_r(_rng(d,[3,6],[6,12],[6,20])); final ans=q*c;
    return Question(questionText:'$a ÷ $b × $c = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a ÷ $b = $q ثم × $c',explanation:'$q × $c = $ans');
  }
  // a - b × c + d  (Hard:Q66 955-133×6+459=616, Q68 955-233×3+69=325)
  Question _p_a_m_bxc_d(Difficulty d) {
    final b=_r(_rng(d,[3,10],[10,50],[100,660])), c=_r(_rng(d,[2,4],[3,5],[3,8])), dd=_r(_rng(d,[5,20],[30,150],[50,500]));
    final a=b*c+_r(_rng(d,[10,40],[50,300],[100,1200])); final ans=a-b*c+dd;
    if(ans<0) return _p_axb_c(d);
    return Question(questionText:'$a - $b × $c + $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'الضرب أولاً: $b×$c=${b*c}',explanation:'$a - ${b*c} + $dd = ${a-b*c} + $dd = $ans');
  }
  // a + b + c ÷ d  (Hard:Q50 255+371+174÷6=655)
  Question _p_a_b_cd(Difficulty d) {
    final a=_r(_rng(d,[10,50],[50,200],[200,955])), b=_r(_rng(d,[10,40],[50,200],[200,800])), dd=_r(_rng(d,[2,4],[3,6],[4,10])), cq=_r(_rng(d,[3,15],[10,40],[20,200]));
    final c=cq*dd; final ans=a+b+cq;
    return Question(questionText:'$a + $b + $c ÷ $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'القسمة أولاً: $c÷$dd=$cq',explanation:'$a + $b + $cq = $ans');
  }
  // a × b ÷ c + d × e  (Hard:Q16 21×8÷6+17×11=215)
  Question _p_axbd_cxe(Difficulty d) {
    final c=_r(_rng(d,[2,4],[3,8],[4,22])), q1=_r(_rng(d,[3,15],[5,40],[10,88]));
    final ab=q1*c; final a=_findFactor(ab); final b=ab~/a;
    if(b<2) return _p_axb_cxd(d);
    final dd=_r(_rng(d,[3,12],[5,20],[10,50])), e=_r(_rng(d,[2,8],[3,15],[5,20]));
    final ans=q1+dd*e;
    return Question(questionText:'$a × $b ÷ $c + $dd × $e = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'($a×$b÷$c) + ($dd×$e)',explanation:'$q1 + ${dd*e} = $ans');
  }

  // a × b ÷ c - d  (Med:Q37 115×6÷5-56=82, Hard:Q27 66×22÷6-177=65, Q55 450×9÷6-134=541)
  Question _p_axbd_m_c(Difficulty d) {
    final c=_r(_rng(d,[2,4],[4,6],[4,10]));
    int q,dd; do {
      q=_r(_rng(d,[5,20],[20,80],[50,200])); dd=_r(_rng(d,[3,15],[30,100],[50,500]));
    } while(q<=dd);
    final ab=q*c; final a=_findFactor(ab); final b=ab~/a;
    if(b<2) return _p_axb_c(d);
    final ans=q-dd;
    return Question(questionText:'$a × $b ÷ $c - $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a×$b=$ab، $ab÷$c=$q، -$dd',explanation:'$a × $b ÷ $c - $dd = $q - $dd = $ans');
  }

  // a ÷ b × c - d  (Hard:Q56 485÷5×12-666=498, Q61 658÷7×12-954=174, Q62 762÷6×4-246=262)
  Question _p_adb_xc_m_d(Difficulty d) {
    final b=_r(_rng(d,[2,4],[5,8],[5,10])), q=_r(_rng(d,[5,15],[15,50],[50,200]));
    final a=q*b; final c=_r(_rng(d,[2,6],[5,12],[4,12]));
    final qc=q*c; final dd=_r(_rng(d,[3,20],[30,200],[100,954]));
    if(qc<=dd) return _p_adb_xc_d(d);
    final ans=qc-dd;
    return Question(questionText:'$a ÷ $b × $c - $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a÷$b=$q، $q×$c=$qc، -$dd',explanation:'$a ÷ $b × $c - $dd = $qc - $dd = $ans');
  }

  // a + b ÷ c × d  PEMDAS (Med:Q13 18+15×5÷3=43, Hard:Q42 144+666÷9×4=440)
  Question _p_a_bdxc(Difficulty d) {
    final a=_r(_rng(d,[5,20],[18,50],[100,300])), c=_r(_rng(d,[2,4],[3,5],[5,9]));
    final q=_r(_rng(d,[3,10],[5,25],[20,80])); final b=q*c;
    final dd=_r(_rng(d,[2,4],[3,5],[3,6])); final ans=a+q*dd;
    return Question(questionText:'$a + $b ÷ $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'القسمة والضرب أولاً: $b÷$c=$q، $q×$dd=${q*dd}',explanation:'$a + ($b÷$c×$dd) = $a + ${q*dd} = $ans');
  }

  // a ÷ b + c × d  PEMDAS (Med:Q47 250÷10+9×5=70, Hard:Q57 528÷6+17×7=207, Q60 645÷5+99×9=1020)
  Question _p_adb_cxd(Difficulty d) {
    final b=_r(_rng(d,[2,5],[5,10],[5,8])), q=_r(_rng(d,[3,15],[10,30],[50,200]));
    final a=q*b; final c=_r(_rng(d,[2,8],[9,20],[17,99])), dd=_r(_rng(d,[2,5],[3,7],[5,9]));
    final ans=q+c*dd;
    return Question(questionText:'$a ÷ $b + $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'($a÷$b) + ($c×$dd) = $q + ${c*dd}',explanation:'$q + ${c*dd} = $ans');
  }

  // a × b × c - d  (Hard:Q36 112×9×2-1090=926)
  Question _p_axbxc_m_d(Difficulty d) {
    final a=_r(_rng(d,[2,8],[10,30],[50,200])), b=_r(_rng(d,[2,5],[3,9],[5,12])), c=_r(_rng(d,[2,3],[2,4],[2,5]));
    final prod=a*b*c; final dd=_r(_rng(d,[3,20],[50,200],[200,1500]));
    if(prod<=dd) return _p_axbxc(d);
    final ans=prod-dd;
    return Question(questionText:'$a × $b × $c - $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a×$b×$c=$prod ثم -$dd',explanation:'$prod - $dd = $ans');
  }

  // a ÷ b ÷ c × d  (Hard:Q64 945÷5÷3×12=756)
  Question _p_adbd_xc(Difficulty d) {
    final b=_r(_rng(d,[2,3],[3,5],[3,7])), c=_r(_rng(d,[2,3],[3,5],[3,5]));
    final q2=_r(_rng(d,[3,10],[10,30],[30,100])); final q1=q2*c; final a=q1*b;
    final dd=_r(_rng(d,[2,6],[5,12],[6,20])); final ans=q2*dd;
    return Question(questionText:'$a ÷ $b ÷ $c × $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$a÷$b=$q1، $q1÷$c=$q2، ×$dd',explanation:'$a ÷ $b ÷ $c × $dd = $q2 × $dd = $ans');
  }

  // a - b × c - d  (Hard:Q59 6060-660×6-616=1484)
  Question _p_a_m_bxc_m_d(Difficulty d) {
    final b=_r(_rng(d,[3,10],[20,100],[100,660])), c=_r(_rng(d,[2,4],[3,6],[3,8])), dd=_r(_rng(d,[3,15],[30,150],[100,900]));
    final bc=b*c; final a=bc+dd+_r(_rng(d,[10,50],[50,400],[200,2000]));
    final ans=a-bc-dd;
    if(ans<0) return _p_axb_c(d);
    return Question(questionText:'$a - $b × $c - $dd = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'الضرب أولاً: $b×$c=$bc، ثم $a-$bc-$dd',explanation:'$a - $bc - $dd = ${a-bc} - $dd = $ans');
  }

  // --- Fraction Words (ثلث، نصف، خمس...) ---
  Question _fractionWordQ(Difficulty d) {
    final fracs = switch(d) {
      Difficulty.easy => [(2,'نصف'),(3,'ثلث'),(4,'ربع')],
      Difficulty.medium => [(3,'ثلث'),(4,'ربع'),(5,'خمس'),(6,'سدس')],
      Difficulty.hard => [(5,'خمس'),(6,'سدس'),(7,'سبع'),(8,'ثمن'),(9,'تسع'),(10,'عشر')],
    };
    final (div,name) = fracs[_random.nextInt(fracs.length)];
    final ans=_r(_rng(d,[5,50],[10,200],[15,400])); final num=ans*div;
    return Question(questionText:'كم يساوي $name $num ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'$name = القسمة على $div',explanation:'$name $num = $num ÷ $div = $ans');
  }

  // --- Time Conversion ---
  Question _timeConvQ(Difficulty d) {
    final t=_random.nextInt(d==Difficulty.easy?3:5); int q,ans; String qt,h,ex;
    switch(t) {
      case 0: q=_r(_rng(d,[2,10],[5,30],[10,60])); ans=q*60; qt='عدد الثواني في $q دقائق = ؟'; h='الدقيقة = 60 ثانية'; ex='$q × 60 = $ans';
      case 1: q=_r(_rng(d,[2,8],[3,20],[5,48])); ans=q*60; qt='عدد الدقائق في $q ساعات = ؟'; h='الساعة = 60 دقيقة'; ex='$q × 60 = $ans';
      case 2: q=_r(_rng(d,[2,7],[2,14],[3,30])); ans=q*24; qt='عدد الساعات في $q أيام = ؟'; h='اليوم = 24 ساعة'; ex='$q × 24 = $ans';
      case 3: q=_r(_rng(d,[2,8],[4,20],[8,52])); ans=q*7; qt='عدد الأيام في $q أسابيع = ؟'; h='الأسبوع = 7 أيام'; ex='$q × 7 = $ans';
      default: q=_r(_rng(d,[2,8],[4,15],[8,30])); ans=q*7; qt='عدد الأيام في $q أسابيع = ؟'; h='الأسبوع = 7 أيام'; ex='$q × 7 = $ans';
    }
    return Question(questionText:qt,correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:h,explanation:ex);
  }

  // --- Calendar & Unit ---
  Question _calendarQ(Difficulty d) {
    final t=_random.nextInt(3); int ans; String qt,h,ex;
    switch(t) {
      case 0: final y=_r(_rng(d,[1,5],[3,15],[5,30])); ans=y*12; qt='عدد الشهور في $y سنوات = ؟'; h='السنة = 12 شهراً'; ex='$y × 12 = $ans';
      case 1:
        final dec=_r([1,3]); final half=_random.nextBool(); final y=dec*10+(half?5:0); ans=y*12;
        final lbl=half?'$dec عقد ونصف':'$dec عقود';
        qt='عدد الشهور في $lbl = ؟'; h='العقد = 120 شهر'; ex='$y × 12 = $ans';
      default:
        final div=[5,10,25,50,100][_random.nextInt(5)]; final cnt=_r(_rng(d,[10,100],[50,500],[100,1000])); final num=cnt*div;
        final nm=switch(div){5=>'الخمسات',10=>'العشرات',25=>'الخمسة والعشرينات',50=>'الخمسينات',_=>'المئات'};
        ans=cnt; qt='عدد $nm في $num = ؟'; h='اقسم على $div'; ex='$num ÷ $div = $ans';
    }
    return Question(questionText:qt,correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:h,explanation:ex);
  }

  // --- Geometry Counting ---
  Question _geometryQ(Difficulty d) {
    final shapes = {'مثلث':3,'مربع':4,'مخمس':5,'مسدس':6};
    final names = shapes.keys.toList();
    final s1=names[_random.nextInt(names.length)]; String s2; do{s2=names[_random.nextInt(names.length)];}while(s2==s1);
    final n1=_r(_rng(d,[2,5],[3,8],[5,15])), n2=_r(_rng(d,[1,4],[2,6],[3,10]));
    final ans=n1*shapes[s1]!+n2*shapes[s2]!;
    final p1=n1>1?'${s1}ات':s1, p2=n2>1?'${s2}ات':s2;
    return Question(questionText:'مجموع أضلاع $n1 $p1 و$n2 $p2 = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),
      hint:'$s1=${shapes[s1]} أضلاع، $s2=${shapes[s2]} أضلاع',explanation:'($n1×${shapes[s1]}) + ($n2×${shapes[s2]}) = ${n1*shapes[s1]!} + ${n2*shapes[s2]!} = $ans');
  }

  // --- Direct Multiply (حاصل ضرب)  (Q69-75: 6×16, 9×12, 15×11, 40×60) ---
  Question _directMulQ(Difficulty d) {
    final a=_r(_rng(d,[2,10],[6,22],[15,60])), b=_r(_rng(d,[2,8],[5,16],[7,60])); final ans=a*b;
    return Question(questionText:'حاصل ضرب $a × $b = ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'اضرب $a في $b',explanation:'$a × $b = $ans');
  }

  // --- Percentage ---
  Question _percentQ(Difficulty d) {
    int p,n; switch(d) {
      case Difficulty.easy: p=[10,25,50][_random.nextInt(3)]; n=(_random.nextInt(5)+1)*20;
      case Difficulty.medium: p=[10,15,20,25,30,50,75][_random.nextInt(7)]; n=(_random.nextInt(10)+1)*20;
      case Difficulty.hard: p=[5,10,15,20,25,30,40,50,60,75,80][_random.nextInt(11)]; n=(_random.nextInt(20)+1)*20;
    }
    int ans=(p*n)~/100;
    return Question(questionText:'كم تساوي $p% من $n ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'النسبة = الرقم × النسبة ÷ 100',explanation:'$p% من $n = $ans');
  }

  // --- Missing Number ---
  Question _missingNumQ(Difficulty d) {
    int a,b,result; String op; int mp=_random.nextInt(2);
    switch(d) { case Difficulty.easy: a=_random.nextInt(20)+1;b=_random.nextInt(20)+1;op='+';result=a+b;
      case Difficulty.medium: a=_random.nextInt(12)+2;b=_random.nextInt(12)+2;op='×';result=a*b;
      case Difficulty.hard: a=_random.nextInt(50)+10;b=_random.nextInt(30)+10;op=_random.nextBool()?'+':'-';result=op=='+'?a+b:a-b;if(result<0){op='+';result=a+b;}
    }
    String qt; int ans; if(mp==0){qt='؟ $op $b = $result';ans=a;}else{qt='$a $op ؟ = $result';ans=b;}
    return Question(questionText:qt,correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:'أوجد العدد المجهول بعكس العملية',explanation:'$a $op $b = $result');
  }

  // --- Double / Half ---
  Question _doubleHalfQ(Difficulty d) {
    bool db=_random.nextBool(); int n; switch(d){case Difficulty.easy:n=(_random.nextInt(25)+1)*2;case Difficulty.medium:n=(_random.nextInt(50)+10)*2;case Difficulty.hard:n=(_random.nextInt(100)+50)*2;}
    int ans=db?n*2:n~/2; String op=db?'ضعف':'نصف';
    return Question(questionText:'ما $op العدد $n ؟',correctAnswer:'$ans',type:QuestionType.mentalMath,difficulty:d,weight:_wt(d),bonusXp:_bxp(d),hint:db?'اضرب في 2':'اقسم على 2',explanation:'$op $n = $ans');
  }

  // ==================== MULTIPLICATION TABLE (Full 1-20) ====================
  List<Question> generateFullMultiplicationTable({required int number}) {
    List<Question> questions = [];
    for (int m = 1; m <= 20; m++) {
      final int product = number * m;
      final bool isHard = product > 100 || (m >= 7 && number >= 7);
      final bool isMedium = product > 30 || m >= 4 || number >= 4;
      questions.add(Question(questionText: '$number × $m = ؟', correctAnswer: '${number * m}', type: QuestionType.multiplication,
        difficulty: isHard ? Difficulty.hard : (isMedium ? Difficulty.medium : Difficulty.easy),
        weight: isHard ? 3 : (isMedium ? 2 : 1), bonusXp: isHard ? 5 : (isMedium ? 2 : 0),
        hint: 'جدول الضرب: $number × $m', explanation: '$number × $m = ${number * m}'));
    }
    questions.shuffle(_random);
    return questions;
  }

  List<Question> generateMultiplicationTableQuestions({required int number, int count = 10}) => generateFullMultiplicationTable(number: number);

  // ==================== MIXED ====================
  List<Question> generateMixedQuestions({required Difficulty difficulty, int count = AppConstants.questionsPerLesson}) {
    List<Question> q = [];
    List<Function> g = [()=>_createMultiplicationQuestion(difficulty),()=>_createAdditionQuestion(difficulty),()=>_createSubtractionQuestion(difficulty),()=>_createDivisionQuestion(difficulty),()=>_createSequenceQuestion(difficulty),()=>_createMentalMathQuestion(difficulty)];
    for(int i=0;i<count;i++) q.add(g[_random.nextInt(g.length)]() as Question);
    return q;
  }

  List<Question> generateWeightedMixedQuestions({required Difficulty targetDifficulty, required double mastery, Map<QuestionType,double>? typeWeights, int count = AppConstants.questionsPerLesson}) {
    final plan=_buildDifficultyPlan(targetDifficulty:targetDifficulty,mastery:mastery,count:count);
    final w=<QuestionType,double>{for(final t in QuestionType.values) t:typeWeights?[t]??1.0};
    final pool=w.entries.where((e)=>e.value>0).expand((e)=>List.filled((e.value*10).round().clamp(1,20),e.key)).toList();
    final questions=<Question>[]; for(int i=0;i<plan.length;i++){final t=pool[_random.nextInt(pool.length)];questions.add(_createQuestionByType(t,plan[i]));}
    return questions;
  }

  List<Question> generateMentalMathQuestions({required Difficulty difficulty, int count = AppConstants.questionsPerLesson}) {
    return List.generate(count, (_) => _createMentalMathQuestion(difficulty));
  }
}
