import 'speech_helper_stub.dart'
    if (dart.library.html) 'speech_helper_web.dart'
    if (dart.library.io) 'speech_helper_mobile.dart';

abstract class AppSpeechHelper {
  static AppSpeechHelper? _instance;

  static AppSpeechHelper get instance {
    _instance ??= getSpeechHelper();
    return _instance!;
  }

  Future<bool> initialize({
    required Function(String error) onError,
    required Function(String status) onStatus,
  });

  Future<void> listen({
    required Function(String words) onResult,
  });

  Future<void> stop();

  bool get isListening;
  bool get isAvailable;
}
