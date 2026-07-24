import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Device ASR (speech → text), matching native SpeechRecognizer auto-send flow.
class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _ready;

  Future<bool> init() async {
    _ready = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _ready;
  }

  Future<void> start({
    required void Function(String text) onPartial,
    required void Function(String text) onFinal,
  }) async {
    if (!_ready) {
      final ok = await init();
      if (!ok) throw Exception('Speech recognition unavailable');
    }
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onFinal(result.recognizedWords);
        } else {
          onPartial(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stop() => _speech.stop();
  Future<void> cancel() => _speech.cancel();
}

/// Device TTS (text → speech), matching native ENABLE_SDK=false path.
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = false;
  bool _initialized = false;

  bool get isEnabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (!enabled) {
      await stop();
    }
  }

  Future<void> speak(String text) async {
    if (!_enabled) return;
    final cleaned = _stripHtml(text).trim();
    if (cleaned.isEmpty) return;
    await init();
    await _tts.stop();
    await _tts.speak(cleaned);
  }

  Future<void> stop() async {
    if (_initialized) await _tts.stop();
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
