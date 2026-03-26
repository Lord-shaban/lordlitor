import 'package:audioplayers/audioplayers.dart';

/// High-quality TTS using Google Translate neural voices
/// Reads questions in Egyptian Arabic dialect
class TtsService {
  final AudioPlayer _player = AudioPlayer();
  bool isSpeaking = false;
  void Function(bool)? onSpeakingChanged;

  Future<void> init() async {
    _player.onPlayerStateChanged.listen((state) {
      final speaking = state == PlayerState.playing;
      if (isSpeaking != speaking) {
        isSpeaking = speaking;
        onSpeakingChanged?.call(speaking);
      }
    });
  }

  Future<void> speak(String questionText) async {
    if (isSpeaking) {
      await stop();
      return;
    }

    final speech = questionToSpeech(questionText);
    final url = _buildTtsUrl(speech);

    try {
      isSpeaking = true;
      onSpeakingChanged?.call(true);
      await _player.play(UrlSource(url));
    } catch (_) {
      isSpeaking = false;
      onSpeakingChanged?.call(false);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    isSpeaking = false;
    onSpeakingChanged?.call(false);
  }

  void dispose() {
    _player.dispose();
  }

  String _buildTtsUrl(String text) {
    final encoded = Uri.encodeComponent(text);
    return 'https://translate.google.com/translate_tts'
        '?ie=UTF-8'
        '&tl=ar'
        '&client=tw-ob'
        '&q=$encoded';
  }

  // ═══════════════════════════════════════════════════════
  //  QUESTION → EGYPTIAN ARABIC SPEECH
  // ═══════════════════════════════════════════════════════

  String questionToSpeech(String text) {
    // Arabic word problems — keep text, just convert numbers + symbols
    if (_isArabicText(text)) {
      return _processArabicQuestion(text);
    }

    // "label:\nmath" format
    if (text.contains(':\n')) {
      final parts = text.split(':\n');
      return '${parts[0]}، ${_mathToSpeech(parts[1].trim())}';
    }

    // Pure math: "5 × 3 = ؟"
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
    s = s.replaceAllMapped(RegExp(r'\d+'), (m) => _n(int.parse(m.group(0)!)));
    s = s.replaceAll('×', ' في ');
    s = s.replaceAll('÷', ' على ');
    s = s.replaceAll('+', ' زائد ');
    s = s.replaceAll('-', ' ناقص ');
    s = s.replaceAll('= ؟', ' بيساوي كام');
    s = s.replaceAll('=', ' يساوي ');
    s = s.replaceAll('؟', ' كام');
    s = s.replaceAll('%', ' في المية');
    s = s.replaceAll('\n', '، ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _mathToSpeech(String math) {
    final tokens = math.trim().split(RegExp(r'\s+'));
    final result = <String>[];

    for (final t in tokens) {
      switch (t) {
        case '×': result.add('في'); break;
        case '÷': result.add('على'); break;
        case '+': result.add('زائد'); break;
        case '-': result.add('ناقص'); break;
        case '=': result.add('بيساوي'); break;
        case '؟': case '?': result.add('كام'); break;
        default:
          if (RegExp(r'^\d+$').hasMatch(t)) {
            result.add(_n(int.parse(t)));
          } else {
            result.add(t);
          }
      }
    }
    return result.join(' ');
  }

  // ═══════════════════════════════════════════════════════
  //  NUMBER → EGYPTIAN ARABIC
  // ═══════════════════════════════════════════════════════

  static const _ones = ['', 'واحد', 'اتنين', 'تلاتة', 'اربعة', 'خمسة', 'ستة', 'سبعة', 'تمانية', 'تسعة'];
  static const _teens = ['عشرة', 'حداشر', 'اتناشر', 'تلتاشر', 'اربعتاشر', 'خمستاشر', 'ستاشر', 'سبعتاشر', 'تمنتاشر', 'تسعتاشر'];
  static const _tens = ['', '', 'عشرين', 'تلاتين', 'اربعين', 'خمسين', 'ستين', 'سبعين', 'تمانين', 'تسعين'];

  String _n(int n) {
    if (n < 0) return 'سالب ${_n(-n)}';
    if (n == 0) return 'صفر';
    if (n <= 9) return _ones[n];
    if (n <= 19) return _teens[n - 10];

    if (n <= 99) {
      final t = n ~/ 10, o = n % 10;
      return o == 0 ? _tens[t] : '${_ones[o]} و${_tens[t]}';
    }

    if (n <= 999) {
      final h = n ~/ 100, r = n % 100;
      final hs = h == 1 ? 'مية' : h == 2 ? 'ميتين' : '${_ones[h]}مية';
      return r == 0 ? hs : '$hs و${_n(r)}';
    }

    if (n <= 9999) {
      final k = n ~/ 1000, r = n % 1000;
      final ks = k == 1 ? 'ألف' : k == 2 ? 'ألفين' : k <= 10 ? '${_ones[k]} تلاف' : '${_n(k)} ألف';
      return r == 0 ? ks : '$ks و${_n(r)}';
    }

    return n.toString();
  }
}
