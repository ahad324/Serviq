import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_helper.dart';

AppSpeechHelper getSpeechHelper() => MobileSpeechHelper();

class MobileSpeechHelper implements AppSpeechHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  Function(String)? _onResultCallback;
  Function(String)? _onErrorCallback;
  Function(String)? _onStatusCallback;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize({
    required Function(String error) onError,
    required Function(String status) onStatus,
  }) async {
    _onErrorCallback = onError;
    _onStatusCallback = onStatus;

    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          _isListening = false;
          _onErrorCallback?.call(val.errorString);
        },
        onStatus: (val) {
          if (val == 'listening') {
            _isListening = true;
          } else if (val == 'notListening' || val == 'done') {
            _isListening = false;
          }
          _onStatusCallback?.call(val);
        },
      );
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      onError(e.toString());
      return false;
    }
  }

  @override
  Future<void> listen({
    required Function(String words) onResult,
  }) async {
    if (!_isAvailable) return;
    _onResultCallback = onResult;
    _isListening = true;
    try {
      await _speech.listen(
        onResult: (result) {
          _onResultCallback?.call(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );
    } catch (e) {
      _isListening = false;
      _onErrorCallback?.call(e.toString());
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      _onErrorCallback?.call(e.toString());
    }
  }
}
