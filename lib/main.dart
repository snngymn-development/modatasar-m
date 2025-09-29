import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/app_error_reporter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppErrorReporter.init(
    dsn: const String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
  );
  AppErrorReporter.guard(() => runApp(const ProviderScope(child: App())));
}
