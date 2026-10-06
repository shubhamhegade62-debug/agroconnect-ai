import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// App ची चार अवस्था: शांत, ऐकत आहे, विचार करत आहे, बोलत आहे
enum VoiceMode { idle, listening, thinking, speaking }

class AIVoicePage extends StatefulWidget {
  const AIVoicePage({super.key});

  @override
  State<AIVoicePage> createState() => _AIVoicePageState();
}

class _AIVoicePageState extends State<AIVoicePage>
    with SingleTickerProviderStateMixin {
  // ⚠️ तुमच्या PC चा IP. Wi-Fi / hotspot बदलला की `ipconfig` मधून नवीन IP इथे टाका.
  static const String serverIp = '10.117.161.4';
  static const String aiUrl = 'http://$serverIp:5001/ai/chat';

  // रंग
  static const Color _green = Color(0xFF078448);
  static const Color _greenLight = Color(0xFF0AA35A);
  static const Color _bg = Color(0xFFF7FBF9);
  static const Color _ink = Color(0xFF18352A);
  static const Color _mint = Color(0xFFEAF6F0);

  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  // सगळ्या animations चा एकच loop (2.4 सेकंद)
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  bool speechAvailable = false;
  bool listening = false;
  bool speaking = false;
  bool thinking = false;

  // true असताना AI बोलून झाल्यावर आपोआप पुन्हा ऐकतो (call सारखं)
  bool conversationOn = false;
  bool _sending = false;
  String _localeId = 'mr_IN';

  String currentText = '';
  String aiText = 'नमस्कार! 🌱\nमी AgroConnect AI आहे.\nमाझ्याशी बोला.';

  VoiceMode get _mode {
    if (speaking) return VoiceMode.speaking;
    if (thinking) return VoiceMode.thinking;
    if (listening) return VoiceMode.listening;
    return VoiceMode.idle;
  }

  String get _statusText {
    switch (_mode) {
      case VoiceMode.speaking:
        return '🔊 AgroConnect AI बोलत आहे';
      case VoiceMode.listening:
        return '🎤 ऐकत आहे...';
      case VoiceMode.thinking:
        return '🧠 विचार करत आहे...';
      case VoiceMode.idle:
        return '🎤 बोलण्यासाठी tap करा';
    }
  }

  @override
  void initState() {
    super.initState();
    _setupVoice();
  }

  // ───────────────────────── VOICE SETUP ─────────────────────────

  Future<void> _setupVoice() async {
    try {
      speechAvailable = await speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => listening = false);
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          if (!mounted) return;
          setState(() => listening = false);
        },
      );

      // फोनमध्ये मराठी उपलब्ध नसेल तर हिंदीवर जा
      if (speechAvailable) {
        final locales = await speech.locales();
        final ids = locales.map((l) => l.localeId).toList();
        if (ids.contains('mr_IN')) {
          _localeId = 'mr_IN';
        } else if (ids.contains('mr-IN')) {
          _localeId = 'mr-IN';
        } else if (ids.contains('hi_IN')) {
          _localeId = 'hi_IN';
        }
      }

      await tts.setLanguage('mr-IN');
      await tts.setSpeechRate(0.48);
      await tts.setPitch(1.0);
      await tts.setVolume(1.0);

      tts.setStartHandler(() {
        if (!mounted) return;
        setState(() => speaking = true);
      });

      tts.setCompletionHandler(() {
        if (!mounted) return;
        setState(() => speaking = false);

        // AI बोलून झाल्यावर पुन्हा ऐकायला तयार
        if (conversationOn) _startListening();
      });

      tts.setCancelHandler(() {
        if (!mounted) return;
        setState(() => speaking = false);
      });

      tts.setErrorHandler((error) {
        debugPrint('TTS error: $error');
        if (!mounted) return;
        setState(() => speaking = false);
      });

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Voice setup error: $e');
    }
  }

  // ───────────────────────── LISTEN ─────────────────────────

  Future<void> _startListening() async {
    if (thinking || speaking) return;

    if (!speechAvailable) {
      await _setupVoice();
    }

    if (!speechAvailable) {
      _showError('Speech Recognition उपलब्ध नाही.');
      return;
    }

    await tts.stop();
    if (!mounted) return;

    setState(() {
      speaking = false;
      listening = true;
      currentText = '';
    });

    await speech.listen(
      localeId: _localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) async {
        if (!mounted) return;

        setState(() => currentText = result.recognizedWords);

        if (result.finalResult) {
          await _stopListeningAndSend();
        }
      },
    );
  }

  Future<void> _stopListeningAndSend() async {
    if (_sending) return; // दोनदा पाठवू नये

    final message = currentText.trim();
    await speech.stop();
    if (!mounted) return;

    setState(() => listening = false);

    if (message.isEmpty) return;

    _sending = true;
    await _askAI(message);
  }

  Future<void> _stopEverything() async {
    conversationOn = false;
    await speech.stop();
    await tts.stop();

    if (!mounted) return;

    setState(() {
      listening = false;
      speaking = false;
      thinking = false;
    });
  }

  // ───────────────────────── AI CALL ─────────────────────────

  Future<void> _askAI(String message) async {
    if (message.isEmpty) {
      _sending = false;
      return;
    }
    if (!mounted) return;

    setState(() {
      thinking = true;
      currentText = message;
    });

    try {
      debugPrint('VOICE USER: $message');

      final response = await http
          .post(
            Uri.parse(aiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 90));

      debugPrint('VOICE STATUS: ${response.statusCode}');
      debugPrint('VOICE RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        conversationOn = false;
        _showError('AI server error: ${response.statusCode}');
        return;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is! Map || data['success'] != true) {
        conversationOn = false;
        _showError(
          data is Map
              ? data['error']?.toString() ?? 'AI response error'
              : 'Invalid AI response',
        );
        return;
      }

      final reply = data['reply']?.toString().trim() ?? '';

      if (reply.isEmpty) {
        conversationOn = false;
        _showError('AI कडून उत्तर आले नाही.');
        return;
      }

      if (!mounted) return;

      setState(() {
        aiText = reply;
        thinking = false;
      });

      await _speak(reply);
    } catch (e) {
      debugPrint('VOICE AI ERROR: $e');
      conversationOn = false;
      _showError('AI शी connection होत नाही.\n$e');
    } finally {
      // काहीही झालं तरी "विचार करत आहे" मध्ये अडकू नये
      _sending = false;
      if (mounted) setState(() => thinking = false);
    }
  }

  /// बोलण्याआधी emoji आणि * # सारखे चिन्ह काढतो, म्हणजे आवाज नैसर्गिक वाटतो
  String _cleanForSpeech(String text) {
    var t = text.replaceAll(RegExp(r'[*#_`~>]'), '');
    t = t.replaceAll(
      RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]', unicode: true),
      '',
    );
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _speak(String text) async {
    try {
      await tts.stop();
      if (!mounted) return;

      setState(() => speaking = true);
      await tts.speak(_cleanForSpeech(text));
    } catch (e) {
      debugPrint('TTS speak error: $e');
      if (!mounted) return;
      setState(() => speaking = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  // ───────────────────────── UI ─────────────────────────

  /// मधला orb: ऐकताना/बोलताना लहरी, विचार करताना फिरणारा चाप, शांत असताना श्वासासारखा
  Widget _buildOrb() {
    final mode = _mode;

    IconData icon;
    switch (mode) {
      case VoiceMode.listening:
        icon = Icons.mic_rounded;
        break;
      case VoiceMode.thinking:
        icon = Icons.eco_rounded;
        break;
      case VoiceMode.speaking:
        icon = Icons.graphic_eq_rounded;
        break;
      case VoiceMode.idle:
        icon = Icons.agriculture_rounded;
        break;
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;

        double pulse;
        switch (mode) {
          case VoiceMode.speaking:
            pulse = 1 + 0.06 * math.sin(2 * math.pi * 3 * t);
            break;
          case VoiceMode.listening:
            pulse = 1 + 0.04 * math.sin(2 * math.pi * 2 * t);
            break;
          case VoiceMode.thinking:
            pulse = 1 + 0.02 * math.sin(2 * math.pi * 2 * t);
            break;
          case VoiceMode.idle:
            pulse = 1 + 0.025 * math.sin(2 * math.pi * t);
            break;
        }

        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: _OrbPainter(t: t, mode: mode, color: _green),
              ),
              Transform.scale(
                scale: pulse,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: mode == VoiceMode.speaking
                          ? const [_greenLight, _green]
                          : const [_green, Color(0xFF05683A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(
                          alpha: mode == VoiceMode.idle ? 0.18 : 0.38,
                        ),
                        blurRadius: mode == VoiceMode.idle ? 20 : 32,
                        spreadRadius: mode == VoiceMode.idle ? 2 : 6,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      icon,
                      key: ValueKey(mode),
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Orb खालची पट्टी: ऐकताना/बोलताना नाचणारे bars, विचार करताना उड्या मारणारे ठिपके
  Widget _buildActivity() {
    final mode = _mode;
    final active = mode == VoiceMode.listening || mode == VoiceMode.speaking;

    return SizedBox(
      height: 48,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;

          if (mode == VoiceMode.thinking) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final y =
                    -10.0 * math.max(0.0, math.sin(2 * math.pi * (t * 2 - i * 0.18)));
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green,
                    ),
                  ),
                );
              }),
            );
          }

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: active ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 350),
            builder: (context, level, _) {
              const count = 13;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(count, (i) {
                  final wave =
                      0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + i * 0.09));
                  // मध्यभागी bars उंच, कडेला लहान
                  final envelope = 0.35 + 0.65 * math.sin(math.pi * (i + 1) / (count + 1));
                  final h = 6.0 + 36.0 * level * wave * envelope;
                  return Container(
                    width: 6,
                    height: h,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: Color.lerp(_greenLight, _green, wave),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatus() {
    final text = _statusText;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }

  Widget _buildUserBubble() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: currentText.isEmpty
            ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
            : Container(
                key: const ValueKey('bubble'),
                width: double.infinity,
                margin: const EdgeInsets.only(left: 22, right: 22, top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: listening
                        ? _greenLight.withValues(alpha: 0.6)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  currentText,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
      ),
    );
  }

  Widget _buildAiBubble() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(aiText),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              aiText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.55,
                color: _ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final active = listening || speaking;

    return SizedBox(
      width: 130,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // बटनाभोवती लाल लहर (ऐकताना/बोलताना)
          if (active)
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final p = (_ctrl.value * 2) % 1.0;
                final size = 76 + 46 * p;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.28 * (1 - p)),
                  ),
                );
              },
            ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();

              if (thinking) return;

              if (listening || speaking) {
                await _stopEverything();
              } else {
                conversationOn = true;
                await _startListening();
              }
            },
            child: AnimatedScale(
              scale: thinking ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thinking
                      ? _green.withValues(alpha: 0.5)
                      : active
                          ? Colors.red
                          : _green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    active ? Icons.call_end_rounded : Icons.mic_rounded,
                    key: ValueKey(active),
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AgroConnect Voice AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildOrb(),
            _buildStatus(),
            const SizedBox(height: 6),
            _buildActivity(),
            _buildUserBubble(),
            _buildAiBubble(),
            _buildMicButton(),
            Text(
              listening || speaking
                  ? 'Tap to stop'
                  : thinking
                      ? 'Please wait...'
                      : 'Tap to talk',
              style: const TextStyle(
                color: Color(0xFF6A7A73),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── ORB PAINTER ─────────────────────────

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.t,
    required this.mode,
    required this.color,
  });

  final double t; // 0..1 loop
  final VoiceMode mode;
  final Color color;

  static const double orbRadius = 56;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;

    switch (mode) {
      case VoiceMode.listening:
      case VoiceMode.speaking:
        {
          final speed = mode == VoiceMode.speaking ? 2 : 1;
          for (var i = 0; i < 3; i++) {
            final p = ((t * speed) + i / 3) % 1.0;
            final r = orbRadius +
                (maxR - orbRadius) * Curves.easeOut.transform(p);
            final paint = Paint()
              ..color = color.withValues(alpha: 0.28 * (1 - p));
            canvas.drawCircle(c, r, paint);
          }
          break;
        }

      case VoiceMode.thinking:
        {
          final rect = Rect.fromCircle(center: c, radius: orbRadius + 18);

          final main = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = color;
          canvas.drawArc(rect, 2 * math.pi * t, math.pi * 1.1, false, main);

          final tail = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: 0.3);
          canvas.drawArc(
            rect,
            2 * math.pi * t + math.pi,
            math.pi * 0.6,
            false,
            tail,
          );
          break;
        }

      case VoiceMode.idle:
        {
          final breathe = math.sin(2 * math.pi * t);
          canvas.drawCircle(
            c,
            orbRadius + 12 + 6 * breathe,
            Paint()..color = color.withValues(alpha: 0.08),
          );
          canvas.drawCircle(
            c,
            orbRadius + 4 + 3 * breathe,
            Paint()..color = color.withValues(alpha: 0.12),
          );
          break;
        }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.t != t || old.mode != mode || old.color != color;
}