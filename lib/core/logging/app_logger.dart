import 'package:talker_flutter/talker_flutter.dart';
import 'observers/file_log_observer.dart';

export 'extensions/logging_extensions.dart';

/// Professional Logger instance for the Serviq application.
late final Talker appLogger;
late final FileLogObserver fileLogObserver;

void initLogger() {
  fileLogObserver = FileLogObserver();
  
  appLogger = TalkerFlutter.init(
    settings: TalkerSettings(
      maxHistoryItems: 1000,
      useConsoleLogs: true,
    ),
  );
  
  appLogger.configure(observer: fileLogObserver);
}
