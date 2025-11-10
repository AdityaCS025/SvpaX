import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Speech message model
class SpeechMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  SpeechMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class SpeechProvider with ChangeNotifier {
  static const String _baseUrl = 'http://localhost:5001';

  // State variables
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isSpeechSupported = false;
  bool _soundEnabled = true;
  String? _error;
  List<SpeechMessage> _conversation = [];
  DateTime? _lastSpeechTime; // Track last speech time for debouncing

  // Flutter STT/TTS instances
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;

  // Getters
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  bool get isSpeechSupported => _isSpeechSupported;
  bool get isActive => _isListening || _isProcessing || _isSpeaking;
  bool get soundEnabled => _soundEnabled;
  String? get error => _error;
  List<SpeechMessage> get conversation => List.unmodifiable(_conversation);

  SpeechProvider() {
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechToText = SpeechToText();
      _flutterTts = FlutterTts();

      // Initialize Speech to Text
      _isSpeechSupported = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      // Configure TTS
      await _configureTts();

      debugPrint('Speech services initialized: $_isSpeechSupported');
    } catch (e) {
      _isSpeechSupported = false;
      debugPrint('Speech initialization failed: $e');
      _handleSpeechError('Failed to initialize speech services: $e');
    }
    notifyListeners();
  }

  Future<void> _configureTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      // Set TTS callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        // Don't treat interruption as an error - it's normal when stopping/starting speech
        if (msg.toString().toLowerCase().contains('interrupted') ||
            msg.toString().toLowerCase().contains('cancel')) {
          debugPrint('TTS interrupted (normal): $msg');
          _isSpeaking = false;
          notifyListeners();
        } else {
          // Only show actual TTS errors to user
          _handleSpeechError('TTS error: $msg');
          _isSpeaking = false;
          notifyListeners();
        }
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('TTS configuration failed: $e');
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');

    switch (status) {
      case 'listening':
        _isListening = true;
        _clearError();
        break;
      case 'notListening':
        _isListening = false;
        break;
      case 'done':
        _isListening = false;
        break;
    }
    notifyListeners();
  }

  void _onSpeechError(dynamic error) {
    String errorMessage = 'Speech recognition error';

    if (error.errorMsg != null) {
      switch (error.errorMsg) {
        case 'error_no_match':
          errorMessage = 'No speech detected. Please try speaking again.';
          break;
        case 'error_audio':
          errorMessage = 'Audio capture failed. Check microphone permissions.';
          break;
        case 'error_permission':
          errorMessage =
              'Microphone permission denied. Please enable microphone access.';
          break;
        case 'error_network':
          errorMessage = 'Network error during speech recognition.';
          break;
        case 'error_speech_timeout':
          errorMessage = 'Speech recognition timeout. Please try again.';
          break;
        default:
          errorMessage = 'Speech error: ${error.errorMsg}';
      }
    }

    _handleSpeechError(errorMessage);
  }

  Future<void> startListening() async {
    if (!_isSpeechSupported || isActive) return;

    try {
      _clearError();

      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (!available) {
        throw Exception('Speech recognition not available');
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        cancelOnError: true,
      );
    } catch (e) {
      _handleSpeechError('Failed to start speech recognition: $e');
    }
  }

  void _onSpeechResult(result) {
    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      final transcript = result.recognizedWords.trim();
      debugPrint('Speech result: $transcript');
      _processSpeechInput(transcript);
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListening = false;
    notifyListeners();
  }

  Future<void> _processSpeechInput(String transcript) async {
    if (transcript.trim().isEmpty) return;

    _isListening = false;
    _addUserMessage(transcript);

    await _processConversationWithAI(transcript);
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || isActive) return;

    _addUserMessage(text);
    await _processConversationWithAI(text);
  }

  void _addUserMessage(String text) {
    _conversation.add(
      SpeechMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

  void _addAssistantMessage(String text) {
    _conversation.add(
      SpeechMessage(text: text, isUser: false, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

  Future<void> _processConversationWithAI(String userInput) async {
    try {
      _isProcessing = true;
      _clearError();
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/speech/conversation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': userInput,
          'conversation': _conversation
              .map(
                (msg) => {
                  'role': msg.isUser ? 'user' : 'assistant',
                  'content': msg.text,
                },
              )
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assistantResponse = data['response'] as String;

        _addAssistantMessage(assistantResponse);

        // Automatically speak the response only if sound is enabled
        if (_soundEnabled) {
          await _speakText(assistantResponse);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _handleSpeechError('Failed to process conversation: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Helper function to remove emojis from text
  String _removeEmojis(String text) {
    // Regular expression to match most emojis and special symbols
    final emojiRegExp = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F018}-\u{1F270}]|[\u{238C}]|[\u{2194}-\u{2199}]|[\u{21A9}-\u{21AA}]|[\u{2934}-\u{2935}]|[\u{23CF}]|[\u{23E9}-\u{23F3}]|[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|[\u{25E6}]|[\u{2B05}-\u{2B07}]|[\u{2B1B}-\u{2B1C}]|[\u{2B50}]|[\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]',
      unicode: true,
    );

    return text.replaceAll(emojiRegExp, '').trim();
  }

  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty || !_soundEnabled) return;

    try {
      // Debounce mechanism - prevent speech requests within 500ms of each other
      final now = DateTime.now();
      if (_lastSpeechTime != null &&
          now.difference(_lastSpeechTime!).inMilliseconds < 500) {
        debugPrint('Speech request debounced');
        return;
      }
      _lastSpeechTime = now;

      // Stop any current speech first
      await stopSpeaking();

      // Small delay to ensure the previous speech is fully stopped
      await Future.delayed(const Duration(milliseconds: 150));

      // Remove emojis from text before speaking
      final cleanText = _removeEmojis(text);
      if (cleanText.isEmpty) return;

      // Check if sound is still enabled (might have been disabled during delay)
      if (!_soundEnabled) return;

      _isSpeaking = true;
      notifyListeners();

      await _flutterTts.speak(cleanText);
    } catch (e) {
      // Only show real errors, not interruption errors
      if (!e.toString().toLowerCase().contains('interrupted')) {
        _handleSpeechError('Failed to speak text: $e');
      }
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> speakText(String text) async {
    await _speakText(text);
  }

  Future<void> stopSpeaking() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
      }
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      // Don't log interruption as an error - it's expected behavior
      if (!e.toString().toLowerCase().contains('interrupted')) {
        debugPrint('Error stopping TTS: $e');
      }
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Toggle sound on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    if (!_soundEnabled && _isSpeaking) {
      // Stop current speech when muting, but don't await to avoid blocking UI
      stopSpeaking();
    }
    notifyListeners();
  }

  // New: Set sound enabled/disabled
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!_soundEnabled) {
      stopSpeaking(); // Stop any current speech when sound is disabled
    }
    notifyListeners();
  }

  void clearConversation() {
    _conversation.clear();
    stopSpeaking();
    stopListening();
    _clearError();
    notifyListeners();
  }

  void _handleSpeechError(String error) {
    _error = error;
    _isListening = false;
    _isProcessing = false;
    _isSpeaking = false;
    debugPrint('Speech error: $error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get available voices (Flutter TTS)
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  // Set voice by name
  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      debugPrint('Error setting voice: $e');
    }
  }

  @override
  void dispose() {
    stopSpeaking();
    stopListening();
    super.dispose();
  }
}
