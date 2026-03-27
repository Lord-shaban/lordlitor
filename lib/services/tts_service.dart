import 'package:flutter_tts/flutter_tts.dart';

/// Offline TTS service — Modern Standard Arabic (فصحى)
/// Converts math questions to clearly spoken Arabic text
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  void Function(bool)? onSpeakingChanged;

  Future<void> init() async {
    // Standard Arabic for clear فصحى pronunciation
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

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
  //  QUESTION → FUSHA ARABIC SPEECH
  // ═══════════════════════════════════════════════════════

  String questionToSpeech(String text) {
    if (_isArabicText(text)) return _processArabicQuestion(text);
    if (text.contains(':\n')) {
      final p = text.split(':\n');
      return '${p[0]}، ${_mathToSpeech(p[1].trim())}';
    }
    return _mathToSpeech(text);
  }

  bool _isArabicText(String t) {
    const s = ['ما ', 'كم ', 'عدد ', 'حاصل ', 'مجموع ',
      'ثلث', 'نصف', 'ربع', 'خمس', 'سدس', 'سبع', 'ثمن', 'تسع', 'عشر',
      'إذا', 'اذا', 'احسب', 'أوجد', 'اوجد'];
    return s.any((x) => t.startsWith(x));
  }

  String _processArabicQuestion(String text) {
    String s = text;
    s = s.replaceAllMapped(RegExp(r'\d+'), (m) => _num(int.parse(m.group(0)!)));
    s = s.replaceAll('×', ' ضَرب ');
    s = s.replaceAll('÷', ' على ');
    s = s.replaceAll('+', ' زائِد ');
    s = s.replaceAll('-', ' ناقِص ');
    s = s.replaceAll('= ؟', ' يُساوي كَم؟');
    s = s.replaceAll('=', ' يُساوي ');
    s = s.replaceAll('؟', ' كَم؟');
    s = s.replaceAll('%', ' بِالمِئَة');
    s = s.replaceAll('\n', '، ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _mathToSpeech(String math) {
    final tokens = math.trim().split(RegExp(r'\s+'));
    final r = <String>[];
    for (final t in tokens) {
      switch (t) {
        case '×': r.add('ضَرب'); break;
        case '÷': r.add('على'); break;
        case '+': r.add('زائِد'); break;
        case '-': r.add('ناقِص'); break;
        case '=': r.add('يُساوي'); break;
        case '؟': case '?': r.add('كَم'); break;
        default:
          if (RegExp(r'^\d+$').hasMatch(t)) {
            r.add(_num(int.parse(t)));
          } else {
            r.add(t);
          }
      }
    }
    return r.join(' ');
  }

  // ═══════════════════════════════════════════════════════
  //  NUMBER → FUSHA ARABIC WORDS (with tashkeel)
  // ═══════════════════════════════════════════════════════

  static const _ones = [
    '', 'واحِد', 'اِثنان', 'ثَلاثَة', 'أَربَعَة', 'خَمسَة',
    'سِتَّة', 'سَبعَة', 'ثَمانِيَة', 'تِسعَة',
  ];

  static const _teens = [
    'عَشَرَة', 'أَحَدَ عَشَر', 'اِثنا عَشَر', 'ثَلاثَةَ عَشَر',
    'أَربَعَةَ عَشَر', 'خَمسَةَ عَشَر', 'سِتَّةَ عَشَر',
    'سَبعَةَ عَشَر', 'ثَمانِيَةَ عَشَر', 'تِسعَةَ عَشَر',
  ];

  static const _tens = [
    '', '', 'عِشرون', 'ثَلاثون', 'أَربَعون', 'خَمسون',
    'سِتّون', 'سَبعون', 'ثَمانون', 'تِسعون',
  ];

  String _num(int n) {
    if (n < 0) return 'سالِب ${_num(-n)}';
    if (n == 0) return 'صِفر';
    if (n <= 9) return _ones[n];
    if (n <= 19) return _teens[n - 10];

    if (n <= 99) {
      final t = n ~/ 10, o = n % 10;
      return o == 0 ? _tens[t] : '${_ones[o]} وَ${_tens[t]}';
    }

    if (n <= 999) {
      final h = n ~/ 100, r = n % 100;
      String hs;
      if (h == 1) hs = 'مِئَة';
      else if (h == 2) hs = 'مِئَتان';
      else hs = '${_ones[h]}مِئَة';
      return r == 0 ? hs : '$hs وَ${_num(r)}';
    }

    if (n <= 9999) {
      final k = n ~/ 1000, r = n % 1000;
      String ks;
      if (k == 1) ks = 'أَلف';
      else if (k == 2) ks = 'أَلفان';
      else if (k <= 10) ks = '${_ones[k]} آلاف';
      else ks = '${_num(k)} أَلف';
      return r == 0 ? ks : '$ks وَ${_num(r)}';
    }

    return n.toString();
  }
}
