import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../logging/talker_config.dart';

/// Firebase push notifications service
///
/// Usage:
/// ```dart
/// final notifications = FirebaseNotifications();
/// await notifications.initialize();
/// ```
class FirebaseNotifications {
  static FirebaseNotifications? _instance;
  static FirebaseNotifications get instance =>
      _instance ??= FirebaseNotifications._();

  FirebaseNotifications._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _backgroundMessageSubscription;

  /// Initialize Firebase notifications
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      TalkerConfig.logInfo('Firebase notifications initialized successfully');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize Firebase notifications',
        e,
        stackTrace,
      );
    }
  }

  /// Request notification permission
  Future<bool> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      TalkerConfig.logInfo('Notification permission granted: $isGranted');
      return isGranted;
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to request notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      TalkerConfig.logInfo('FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get FCM token', e, stackTrace);
      return null;
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Background messages
    _backgroundMessageSubscription = FirebaseMessaging.onMessageOpenedApp
        .listen(_handleBackgroundMessage);

    // Terminated app messages
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleTerminatedAppMessage(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    TalkerConfig.logInfo('Received foreground message: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    TalkerConfig.logInfo('Received background message: ${message.messageId}');
    _navigateToMessage(message);
  }

  /// Handle terminated app messages
  void _handleTerminatedAppMessage(RemoteMessage message) {
    TalkerConfig.logInfo(
      'Received terminated app message: ${message.messageId}',
    );
    _navigateToMessage(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    TalkerConfig.logInfo('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  /// Navigate to message content
  void _navigateToMessage(RemoteMessage message) {
    // TODO: Implement navigation logic based on message data
    final data = message.data;
    if (data.containsKey('route')) {
      // Navigate to specific route
      TalkerConfig.logInfo('Navigate to route: ${data['route']}');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      TalkerConfig.logInfo('Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to subscribe to topic: $topic',
        e,
        stackTrace,
      );
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      TalkerConfig.logInfo('Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to unsubscribe from topic: $topic',
        e,
        stackTrace,
      );
    }
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Refresh FCM token
  Future<String?> refreshToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      TalkerConfig.logInfo('FCM Token refreshed: $_fcmToken');
      return _fcmToken;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to refresh FCM token', e, stackTrace);
      return null;
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      'Test Notification',
      'This is a test notification from Moda App',
      details,
    );
  }

  /// Dispose resources
  void dispose() {
    _messageSubscription?.cancel();
    _backgroundMessageSubscription?.cancel();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  TalkerConfig.logInfo('Background message received: ${message.messageId}');
}
