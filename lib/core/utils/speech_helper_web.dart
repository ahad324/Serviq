import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'speech_helper.dart';

AppSpeechHelper getSpeechHelper() => WebSpeechHelper();

class WebSpeechHelper implements AppSpeechHelper {
  html.SpeechRecognition? _recognition;
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
      final isSupported = html.SpeechRecognition.supported;
      if (!isSupported) {
        _isAvailable = false;
        onError("Speech recognition not supported in this browser.");
        return false;
      }

      _recognition = html.SpeechRecognition();
      _recognition!.continuous = true;
      _recognition!.interimResults = true;
      _recognition!.lang = 'en-US'; // Supports en-US or ur-PK natively

      _recognition!.onStart.listen((_) {
        _isListening = true;
        _onStatusCallback?.call("listening");
      });

      _recognition!.onEnd.listen((_) {
        _isListening = false;
        _onStatusCallback?.call("notListening");
      });

      (_recognition!.onError as Stream<dynamic>).listen((event) {
        _isListening = false;
        _onErrorCallback?.call(event.toString());
      });

      _recognition!.onResult.listen((event) {
        try {
          final jsEvent = js.JsObject.fromBrowserObject(event);
          final results = jsEvent['results'];
          if (results != null) {
            final index = jsEvent['resultIndex'] as int? ?? 0;
            final result = results[index];
            if (result != null) {
              final alternative = result[0];
              if (alternative != null) {
                final transcript = alternative['transcript'] as String?;
                if (transcript != null) {
                  _onResultCallback?.call(transcript);
                }
              }
            }
          }
        } catch (e) {
          // Fallback if JS parsing has an issue
          final results = event.results;
          if (results != null && results.isNotEmpty) {
            final index = event.resultIndex ?? 0;
            if (index < results.length) {
              final result = results[index];
              try {
                // If native Dart supports item:
                final alternative = (result as dynamic).item(0);
                final transcript = alternative.transcript;
                if (transcript != null) {
                  _onResultCallback?.call(transcript);
                }
              } catch (_) {}
            }
          }
        }
      });

      _isAvailable = true;
      return true;
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
    if (!_isAvailable || _recognition == null) return;
    _onResultCallback = onResult;
    try {
      _recognition!.start();
    } catch (e) {
      _onErrorCallback?.call(e.toString());
    }
  }

  @override
  Future<void> stop() async {
    if (_recognition == null) return;
    try {
      _recognition!.stop();
      _isListening = false;
    } catch (e) {
      _onErrorCallback?.call(e.toString());
    }
  }
}
