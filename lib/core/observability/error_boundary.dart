import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Global error boundary for the application
///
/// Usage:
/// ```dart
/// void main() {
///   setupErrorBoundary();
///   runApp(MyApp());
/// }
/// ```
class ErrorBoundary {
  static void setup() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    // Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };

    // Zone errors
    runZonedGuarded(
      () {
        runApp(const MaterialApp(home: Scaffold()));
      },
      (error, stack) {
        _logError('Zone Error', error, stack);
      },
    );
  }

  static void _logError(String type, Object error, StackTrace? stack) {
    if (kDebugMode) {
      // Development: Use Talker for detailed logging
      final talker = TalkerFlutter.init();
      talker.handle(error, stack, type);
    } else {
      // Production: Send to crash reporting service
      _reportToCrashService(type, error, stack);
    }
  }

  static void _reportToCrashService(
    String type,
    Object error,
    StackTrace? stack,
  ) {
    // TODO: Integrate with Sentry or Firebase Crashlytics
    // Sentry.captureException(error, stackTrace: stack);
    debugPrint('Production Error [$type]: $error');
  }
}

/// Error boundary widget for catching widget tree errors
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace stack)? errorBuilder;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace!) ??
          _DefaultErrorWidget(
            error: _error!,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }
    return widget.child;
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Bir hata oluştu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
