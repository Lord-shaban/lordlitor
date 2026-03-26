import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service with Egyptian Arabic dialect
/// Converts math questions to fully spoken Egyptian Arabic text
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  void Function(bool)? onSpeakingChanged;

  Future<void> init() async {
    await _tts.setLanguage('ar-EG');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(0.95);
    await _tts.setVolume(1.0);

    // Pick best Arabic voice
    try {
      final voices = await _tts.getVoices;
      if (voices != null) {
        final list = List<Map<dynamic, dynamic>>.from(voices);
        // Prefer ar-EG, then any ar
        var picked = list.where((v) => v['locale']?.toString() == 'ar-EG').toList();
        if (picked.isEmpty) {
          picked = list.where((v) => v['locale']?.toString().startsWith('ar') == true).toList();
        }
        if (picked.isNotEmpty) {
          await _tts.setVoice({
            'name': picked.first['name'].toString(),
            'locale': picked.first['locale']?.toString() ?? 'ar-EG',
          });
        }
      }
    } catch (_) {}

    _tts.setStartHandler(() {
      isSpeaking = true;
      onSpeakingChanged?.call(true);
    });
    _tts.setCompletionHandler(() {
      isSpeaking = false;
      onSpeakingChanged?.call(false);
    });
    _tts.setCancelHandler(() {
      isSpeaking = false;
      onSpeakingChanged?.call(false);
    });
  }

  Future<void> speak(String questionText) async {
    if (isSpeaking) {
      await stop();
      return;
    }
    final speech = questionToSpeech(questionText);
    await _tts.speak(speech);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking = false;
    onSpeakingChanged?.call(false);
  }

  void dispose() {
    _tts.stop();
  }

  // ═══════════════════════════════════════════════════════
  //  CONVERT QUESTION → EGYPTIAN ARABIC SPEECH
  // ═══════════════════════════════════════════════════════

  String questionToSpeech(String text) {
    // Handle word problems (Arabic text questions)
    if (_isArabicText(text)) {
      return _processArabicQuestion(text);
    }

    // Handle "label:\nmath" format
    if (text.contains(':\n')) {
      final parts = text.split(':\n');
      final label = parts[0].trim();
      final math = parts[1].trim();
      return '$label، ${_mathToSpeech(math)}';
    }

    // Pure math expression
    return _mathToSpeech(text);
  }

  bool _isArabicText(String text) {
    final starters = ['ما ', 'كم ', 'عدد ', 'حاصل ', 'مجموع ',
      'ثلث', 'نصف', 'ربع', 'خمس', 'سدس', 'سبع', 'ثمن', 'تسع', 'عشر',
      'إذا', 'اذا', 'كام', 'احسب', 'أوجد', 'اوجد'];
    return starters.any((s) => text.startsWith(s));
  }

  String _processArabicQuestion(String text) {
    String s = text;
    // Convert any embedded numbers to Arabic words
    s = s.replaceAllMapped(RegExp(r'\d+'), (m) => _numberToArabic(int.parse(m.group(0)!)));
    s = s.replaceAll('×', ' في ');
    s = s.replaceAll('÷', ' على ');
    s = s.replaceAll('+', ' زائد ');
    s = s.replaceAll('-', ' ناقص ');
    s = s.replaceAll('= ؟', ' بيساوي كام');
    s = s.replaceAll('=', ' يساوي ');
    s = s.replaceAll('؟', ' كام');
    s = s.replaceAll('%', ' في المية');
    s = s.replaceAll('\n', '، ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  String _mathToSpeech(String math) {
    // Tokenize: split by spaces, convert each token
    final tokens = math.trim().split(RegExp(r'\s+'));
    final parts = <String>[];

    for (final token in tokens) {
      if (token == '×') {
        parts.add('في');
      } else if (token == '÷') {
        parts.add('على');
      } else if (token == '+') {
        parts.add('زائد');
      } else if (token == '-') {
        parts.add('ناقص');
      } else if (token == '=') {
        parts.add('بيساوي');
      } else if (token == '؟' || token == '?') {
        parts.add('كام');
      } else if (RegExp(r'^\d+$').hasMatch(token)) {
        parts.add(_numberToArabic(int.parse(token)));
      } else {
        parts.add(token);
      }
    }

    return parts.join(' ');
  }

  // ═══════════════════════════════════════════════════════
  //  NUMBER → EGYPTIAN ARABIC WORDS
  // ═══════════════════════════════════════════════════════

  static const _ones = [
    '', 'واحد', 'اتنين', 'تلاتة', 'اربعة', 'خمسة',
    'ستة', 'سبعة', 'تمانية', 'تسعة',
  ];

  static const _teens = [
    'عشرة', 'حداشر', 'اتناشر', 'تلتاشر', 'اربعتاشر', 'خمستاشر',
    'ستاشر', 'سبعتاشر', 'تمنتاشر', 'تسعتاشر',
  ];

  static const _tens = [
    '', '', 'عشرين', 'تلاتين', 'اربعين', 'خمسين',
    'ستين', 'سبعين', 'تمانين', 'تسعين',
  ];

  String _numberToArabic(int n) {
    if (n < 0) return 'سالب ${_numberToArabic(-n)}';
    if (n == 0) return 'صفر';

    if (n <= 9) return _ones[n];
    if (n <= 19) return _teens[n - 10];

    if (n <= 99) {
      final ten = n ~/ 10;
      final one = n % 10;
      if (one == 0) return _tens[ten];
      return '${_ones[one]} و ${_tens[ten]}';
    }

    if (n <= 999) {
      final hundred = n ~/ 100;
      final rest = n % 100;
      String h;
      if (hundred == 1) {
        h = 'مية';
      } else if (hundred == 2) {
        h = 'ميتين';
      } else {
        h = '${_ones[hundred]}مية';
      }
      if (rest == 0) return h;
      return '$h و ${_numberToArabic(rest)}';
    }

    if (n <= 9999) {
      final thousand = n ~/ 1000;
      final rest = n % 1000;
      String t;
      if (thousand == 1) {
        t = 'الف';
      } else if (thousand == 2) {
        t = 'الفين';
      } else if (thousand <= 10) {
        t = '${_ones[thousand]} تلاف';
      } else {
        t = '${_numberToArabic(thousand)} الف';
      }
      if (rest == 0) return t;
      return '$t و ${_numberToArabic(rest)}';
    }

    // Fallback: read digits
    return n.toString();
  }
}
