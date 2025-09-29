import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppErrorReporter {
  static Future<void> init({required String dsn}) async {
    await SentryFlutter.init((o) => o.dsn = dsn, appRunner: () {});
  }

  static void capture(Object error, [StackTrace? stack]) {
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    } else {
      debugPrint('DEV ERROR: $error\n$stack');
    }
  }

  static void guard(VoidCallback runAppCallback) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      capture(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      capture(error, stack);
      return true;
    };
    runZonedGuarded(runAppCallback, (e, s) => capture(e, s));
  }
}
