import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'talker_config.dart';
import '../di/logging_providers.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? fallbackTitle;
  final String? fallbackMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TalkerWrapper(talker: TalkerConfig.instance, child: child);
  }
}

class ErrorScreen extends ConsumerWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (onRetry != null) ...[
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
                const SizedBox(height: 16),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  // Show Talker logs
                  final talker = ref.read(talkerProvider);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TalkerScreen(talker: talker),
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Logları Görüntüle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
