import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// A professional TalkerObserver that persists all logs and traces 
/// to a physical file on the device.
/// 
/// Note: File logging is disabled on Web as dart:io is not supported.
class FileLogObserver extends TalkerObserver {
  File? _logFile;
  final List<String> _buffer = [];
  bool _initialized = false;

  FileLogObserver() {
    if (!kIsWeb) {
      _initFile();
    } else {
      debugPrint('LOGGING: File logging is not supported on Web. Logs will only appear in Console.');
    }
  }

  Future<void> _initFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // Saving directly in the 'logs' folder within the app's documents directory
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final date = DateTime.now().toIso8601String().split('T').first;
      _logFile = File('${logsDir.path}/$date.log');
      
      final header = '\n--- SESSION START: ${DateTime.now()} ---\n';
      await _logFile?.writeAsString(header, mode: FileMode.append);
      
      debugPrint('LOGGING: Saved to ${_logFile?.path}');
      
      _initialized = true;
      
      // Flush any logs that occurred during initialization
      if (_buffer.isNotEmpty) {
        for (final msg in _buffer) {
          await _writeToFile(msg);
        }
        _buffer.clear();
      }
    } catch (e) {
      debugPrint('LOGGING ERROR: Failed to initialize file: $e');
    }
  }

  @override
  void onLog(TalkerData log) => _handle(log.generateTextMessage());

  @override
  void onError(TalkerError err) => _handle('[ERROR] ${err.generateTextMessage()}');

  @override
  void onException(TalkerException err) => _handle('[EXCEPTION] ${err.generateTextMessage()}');

  void _handle(String text) {
    if (kIsWeb) return; // Don't even buffer on web

    final formatted = '${DateTime.now().toIso8601String()} $text';
    if (!_initialized) {
      _buffer.add(formatted);
    } else {
      _writeToFile(formatted);
    }
  }

  Future<void> _writeToFile(String text) async {
    if (kIsWeb) return;

    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$text\n', mode: FileMode.append, flush: true);
      }
    } catch (_) {
      // Fail silently
    }
  }

  /// Helper to get the current log file path
  Future<String?> getLogPath() async {
    if (kIsWeb) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final path = '${directory.path}/logs/$date.log';
      if (await File(path).exists()) return path;
    } catch (_) {}
    return null;
  }
}
