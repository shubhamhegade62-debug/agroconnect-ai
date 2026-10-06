
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // =========================================================
  // PHONE -> PC FLASK SERVER
  // =========================================================

  static const String _aiUrl =
      'http://10.100.96.4:5001/ai/chat';

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isLoading = false;

  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();

    _messages.add({
      'role': 'ai',
      'message':
          'नमस्कार! 🌱\n'
          'मी AgroConnect AI आहे.\n\n'
          'तुम्ही मला बोलून किंवा लिहून शेतीबद्दल प्रश्न विचारू शकता.',
    });

    _initializeVoice();
  }

  // =========================================================
  // VOICE INITIALIZATION
  // =========================================================

  Future<void> _initializeVoice() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');

          if (!mounted) return;

          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');

          if (!mounted) return;

          setState(() {
            _isListening = false;
          });
        },
      );

      _speechAvailable = available;

      // Marathi TTS
      await _tts.setLanguage('mr-IN');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() {
        if (!mounted) return;

        setState(() {
          _isSpeaking = true;
        });
      });

      _tts.setCompletionHandler(() {
        if (!mounted) return;

        setState(() {
          _isSpeaking = false;
        });
      });

      _tts.setCancelHandler(() {
        if (!mounted) return;

        setState(() {
          _isSpeaking = false;
        });
      });

      _tts.setErrorHandler((message) {
        debugPrint('TTS error: $message');

        if (!mounted) return;

        setState(() {
          _isSpeaking = false;
        });
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Voice initialization error: $e');
    }
  }

  // =========================================================
  // START SPEECH
  // =========================================================

  Future<void> _startListening() async {
    if (_isLoading) return;

    if (!_speechAvailable) {
      await _initializeVoice();
    }

    if (!_speechAvailable) {
      _showMessage(
        'फोनमध्ये Speech Recognition उपलब्ध नाही.',
      );
      return;
    }

    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _isSpeaking = false;
      _isListening = true;
      _messageController.clear();
    });

    await _speech.listen(
      localeId: 'mr_IN',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _messageController.text = result.recognizedWords;

          _messageController.selection =
              TextSelection.fromPosition(
            TextPosition(
              offset: _messageController.text.length,
            ),
          );
        });
      },
    );
  }

  // =========================================================
  // STOP SPEECH
  // =========================================================

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    final text = _messageController.text.trim();

    if (text.isNotEmpty) {
      await _sendMessage();
    }
  }

  // =========================================================
  // MICROPHONE TOGGLE
  // =========================================================

  Future<void> _toggleMicrophone() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _isSpeaking = false;

      _messages.add({
        'role': 'user',
        'message': message,
      });

      _isLoading = true;
    });

    _messageController.clear();

    _scrollToBottom();

    try {
      debugPrint('================================');
      debugPrint('AI REQUEST');
      debugPrint('URL: $_aiUrl');
      debugPrint('MESSAGE: $message');
      debugPrint('================================');

      final response = await http
          .post(
            Uri.parse(_aiUrl),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json; charset=utf-8',
            },
            body: utf8.encode(
              jsonEncode({
                'message': message,
              }),
            ),
          )
          .timeout(
            const Duration(seconds: 180),
          );

      debugPrint(
        'AI STATUS CODE: ${response.statusCode}',
      );

      // =====================================================
      // IMPORTANT:
      // Decode response as UTF-8 explicitly.
      // This helps Marathi / Unicode text.
      // =====================================================

      final String responseText =
          utf8.decode(response.bodyBytes);

      debugPrint(
        'AI RESPONSE: $responseText',
      );

      // =====================================================
      // SUCCESS
      // =====================================================

      if (response.statusCode == 200) {
        final dynamic decoded =
            jsonDecode(responseText);

        if (decoded is Map &&
            decoded['success'] == true) {
          final String reply =
              decoded['reply']?.toString().trim() ??
                  '';

          if (reply.isEmpty) {
            _addErrorMessage(
              'AI कडून रिकामे उत्तर आले.',
            );
            return;
          }

          if (!mounted) return;

          setState(() {
            _messages.add({
              'role': 'ai',
              'message': reply,
            });
          });

          _scrollToBottom();

          // Speak AI response
          await _speak(reply);
        } else {
          final String error =
              decoded is Map
                  ? decoded['error']?.toString() ??
                      'Unknown server error'
                  : 'Invalid server response';

          _addErrorMessage(
            error,
          );
        }
      }

      // =====================================================
      // SERVER ERROR
      // =====================================================

      else {
        _addErrorMessage(
          'AI server error: ${response.statusCode}\n\n'
          '$responseText',
        );
      }
    }

    // =======================================================
    // CONNECTION ERROR
    // =======================================================

    on http.ClientException catch (e) {
      debugPrint(
        'HTTP ClientException: $e',
      );

      _addErrorMessage(
        'AI server शी connection होत नाही.\n\n'
        'फोन आणि PC एकाच Wi-Fi वर आहेत का ते तपासा.',
      );
    }

    // =======================================================
    // TIMEOUT
    // =======================================================

    on TimeoutException catch (e) {
      debugPrint(
        'AI timeout: $e',
      );

      _addErrorMessage(
        'AI response यायला खूप वेळ लागला.\n\n'
        'पुन्हा प्रयत्न करा.',
      );
    }

    // =======================================================
    // JSON / OTHER ERROR
    // =======================================================

    catch (e) {
      debugPrint(
        'AI connection error: $e',
      );

      _addErrorMessage(
        'AI response process करताना error आला.\n\n'
        '$e',
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      _scrollToBottom();
    }
  }

  // =========================================================
  // TEXT TO SPEECH
  // =========================================================

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();

      if (!mounted) return;

      setState(() {
        _isSpeaking = true;
      });

      await _tts.speak(text);
    } catch (e) {
      debugPrint(
        'TTS error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isSpeaking = false;
      });
    }
  }

  // =========================================================
  // STOP SPEAKING
  // =========================================================

  Future<void> _stopSpeaking() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _isSpeaking = false;
    });
  }

  // =========================================================
  // ERROR MESSAGE
  // =========================================================

  void _addErrorMessage(String error) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        'role': 'ai',
        'message':
            'माफ करा 😕\n\n$error',
      });
    });

    _scrollToBottom();
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // SCROLL
  // =========================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =========================================================
  // MESSAGE BUBBLE
  // =========================================================

  Widget _buildMessage(
    Map<String, String> message,
  ) {
    final bool isUser =
        message['role'] == 'user';

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(
          left: 14,
          right: 14,
          top: 6,
          bottom: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF078448)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft:
                Radius.circular(
              isUser ? 18 : 4,
            ),
            bottomRight:
                Radius.circular(
              isUser ? 4 : 18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: 0.05,
              ),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message['message'] ?? '',
          style: TextStyle(
            fontSize: 15.5,
            height: 1.5,
            color: isUser
                ? Colors.white
                : const Color(0xFF18352A),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOADING
  // =========================================================

  Widget _buildLoading() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    Color(0xFF078448),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'AgroConnect AI विचार करत आहे...',
              style: TextStyle(
                fontSize: 14,
                color:
                    Color(0xFF486158),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // VOICE STATUS
  // =========================================================

  Widget _buildVoiceStatus() {
    if (_isListening) {
      return const Padding(
        padding:
            EdgeInsets.only(top: 8),
        child: Text(
          '🎤 ऐकत आहे... बोला',
          style: TextStyle(
            color:
                Color(0xFF078448),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      );
    }

    if (_isSpeaking) {
      return const Padding(
        padding:
            EdgeInsets.only(top: 8),
        child: Text(
          '🔊 AgroConnect AI बोलत आहे...',
          style: TextStyle(
            color:
                Color(0xFF078448),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      );
    }

    return const SizedBox(
      height: 8,
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    _speech.stop();
    _tts.stop();

    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FBF9),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFF078448),
        foregroundColor:
            Colors.white,

        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor:
                  Colors.white,
              child: Icon(
                Icons
                    .agriculture_rounded,
                color:
                    Color(0xFF078448),
                size: 22,
              ),
            ),

            SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'AgroConnect AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  'तुमचा शेती सहाय्यक',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Column(
        children: [

          _buildVoiceStatus(),

          // =================================================
          // CHAT
          // =================================================

          Expanded(
            child:
                ListView.builder(
              controller:
                  _scrollController,

              padding:
                  const EdgeInsets.only(
                top: 8,
                bottom: 12,
              ),

              itemCount:
                  _messages.length +
                  (_isLoading
                      ? 1
                      : 0),

              itemBuilder:
                  (context, index) {

                if (_isLoading &&
                    index ==
                        _messages.length) {
                  return _buildLoading();
                }

                return _buildMessage(
                  _messages[index],
                );
              },
            ),
          ),

          // =================================================
          // INPUT AREA
          // =================================================

          SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                8,
                10,
                10,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha: 0.07,
                    ),
                    blurRadius: 12,
                    offset:
                        const Offset(
                      0,
                      -3,
                    ),
                  ),
                ],
              ),

              child: Row(
                children: [

                  // =========================================
                  // MICROPHONE
                  // =========================================

                  CircleAvatar(
                    radius: 25,

                    backgroundColor:
                        _isListening
                            ? Colors.red
                            : const Color(
                                0xFF078448,
                              ),

                    child:
                        IconButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _toggleMicrophone,

                      icon: Icon(
                        _isListening
                            ? Icons
                                .stop_rounded
                            : Icons
                                .mic_rounded,

                        color:
                            Colors.white,

                        size: 23,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // =========================================
                  // TEXT INPUT
                  // =========================================

                  Expanded(
                    child:
                        TextField(
                      controller:
                          _messageController,

                      textInputAction:
                          TextInputAction
                              .send,

                      onSubmitted:
                          (_) =>
                              _sendMessage(),

                      minLines: 1,
                      maxLines: 4,

                      decoration:
                          InputDecoration(
                        hintText:
                            'बोला किंवा प्रश्न लिहा...',

                        hintStyle:
                            const TextStyle(
                          color:
                              Color(
                            0xFF7A8B84,
                          ),
                          fontSize: 14,
                        ),

                        filled: true,

                        fillColor:
                            const Color(
                          0xFFF1F6F3,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            26,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // =========================================
                  // SEND / STOP
                  // =========================================

                  CircleAvatar(
                    radius: 25,

                    backgroundColor:
                        const Color(
                      0xFF078448,
                    ),

                    child:
                        IconButton(
                      onPressed:
                          _isLoading
                              ? null
                              : (_isSpeaking
                                  ? _stopSpeaking
                                  : _sendMessage),

                      icon: Icon(
                        _isSpeaking
                            ? Icons
                                .stop_rounded
                            : Icons
                                .send_rounded,

                        color:
                            Colors.white,

                        size: 22,
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
}

