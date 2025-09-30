import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/app_error_reporter.dart';
import 'core/performance/performance_monitor.dart';
import 'core/security/rate_limiter.dart';
import 'core/security/audit_logger.dart';
import 'core/security/certificate_pinner.dart';
import 'core/realtime/websocket_service.dart';
import 'core/ai/ai_service.dart';
import 'core/backend/backend_service.dart';
import 'core/config/environment_config.dart';
import 'core/monitoring/production_monitor.dart';
import 'core/sync/database_sync_service.dart';
import 'core/scaling/load_balancer.dart';
// New advanced services
import 'core/network/real_api_service.dart';
import 'core/database/supabase_service.dart';
import 'core/database/migration_service.dart';
import 'core/ai/openai_service.dart';
import 'core/ai/tensorflow_service.dart';
import 'core/animations/animation_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize performance monitoring
  await PerformanceMonitor.instance.initialize();

  // Initialize security features
  await RateLimiter.instance.initialize();
  await AuditLogger.instance.initialize();
  await CertificatePinner.instance.initialize();

  // Initialize API client
  // await ApiClient.instance.initialize();

  // Initialize WebSocket service
  await WebSocketService.instance.connect();
  await AIService().initialize();

  // Initialize environment configuration
  await EnvironmentConfig.instance.initialize();

  // Initialize backend service
  await BackendService().initialize();

  // Initialize production monitoring
  await ProductionMonitor.instance.initialize();

  // Initialize database sync service
  await DatabaseSyncService.instance.initialize();

  // Initialize load balancer
  await LoadBalancer.instance.initialize();

  // Initialize new advanced services
  await RealApiService().initialize();
  await SupabaseService().initialize();
  await MigrationService().initialize();
  await OpenAIService().initialize();
  await TensorFlowService().initialize();
  await AnimationService().initialize();

  await AppErrorReporter.init(
    dsn: const String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
  );

  AppErrorReporter.guard(() {
    runApp(const ProviderScope(child: App()));
  });
}
