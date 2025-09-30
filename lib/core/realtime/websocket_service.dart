import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../logging/talker_config.dart';
import '../config/api_config.dart';

/// WebSocket service for real-time communication
///
/// Usage:
/// ```dart
/// final wsService = WebSocketService();
/// await wsService.connect();
/// wsService.subscribe('sales', (data) => print(data));
/// ```
class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnected = false;
  bool _isConnecting = false;

  final Map<String, List<Function(dynamic)>> _subscribers = {};
  final StreamController<WebSocketEvent> _eventController =
      StreamController.broadcast();

  /// WebSocket event stream
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Check if connecting
  bool get isConnecting => _isConnecting;

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;
      _eventController.add(WebSocketEvent.connecting());

      final config = ApiConfig.instance.websocketConfig;
      final url = config['url'] as String;

      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      _startPingTimer();
      _eventController.add(WebSocketEvent.connected());

      TalkerConfig.logInfo('WebSocket connected to $url');
    } catch (e, stackTrace) {
      _isConnecting = false;
      _eventController.add(WebSocketEvent.error(e.toString()));
      TalkerConfig.logError('Failed to connect WebSocket', e, stackTrace);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    try {
      _pingTimer?.cancel();
      _reconnectTimer?.cancel();

      await _channel?.sink.close(status.goingAway);
      _channel = null;

      _isConnected = false;
      _isConnecting = false;

      _eventController.add(WebSocketEvent.disconnected());
      TalkerConfig.logInfo('WebSocket disconnected');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Error disconnecting WebSocket', e, stackTrace);
    }
  }

  /// Subscribe to a channel
  void subscribe(String channel, Function(dynamic) callback) {
    _subscribers.putIfAbsent(channel, () => []).add(callback);

    // Send subscription message
    _sendMessage({'type': 'subscribe', 'channel': channel});

    TalkerConfig.logInfo('Subscribed to channel: $channel');
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channel, [Function(dynamic)? callback]) {
    if (callback != null) {
      _subscribers[channel]?.remove(callback);
    } else {
      _subscribers.remove(channel);
    }

    // Send unsubscription message
    _sendMessage({'type': 'unsubscribe', 'channel': channel});

    TalkerConfig.logInfo('Unsubscribed from channel: $channel');
  }

  /// Send message to server
  void sendMessage(String type, dynamic data) {
    _sendMessage({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send message internally
  void _sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      TalkerConfig.logWarning('WebSocket not connected, cannot send message');
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to send WebSocket message', e, stackTrace);
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String?;
      final channel = data['channel'] as String?;
      final payload = data['data'];

      switch (type) {
        case 'message':
          _notifySubscribers(channel, payload);
          break;
        case 'pong':
          // Handle pong response
          break;
        case 'error':
          _eventController.add(WebSocketEvent.error(payload.toString()));
          break;
        default:
          TalkerConfig.logWarning('Unknown WebSocket message type: $type');
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to parse WebSocket message', e, stackTrace);
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    _eventController.add(WebSocketEvent.error(error.toString()));
    TalkerConfig.logError('WebSocket error', error);
    _scheduleReconnect();
  }

  /// Handle disconnection
  void _handleDisconnection() {
    _isConnected = false;
    _isConnecting = false;
    _eventController.add(WebSocketEvent.disconnected());
    TalkerConfig.logInfo('WebSocket disconnected');
    _scheduleReconnect();
  }

  /// Notify subscribers of a message
  void _notifySubscribers(String? channel, dynamic data) {
    if (channel == null) return;

    final callbacks = _subscribers[channel];
    if (callbacks != null) {
      for (final callback in callbacks) {
        try {
          callback(data);
        } catch (e, stackTrace) {
          TalkerConfig.logError(
            'Error in WebSocket subscriber callback',
            e,
            stackTrace,
          );
        }
      }
    }
  }

  /// Start ping timer
  void _startPingTimer() {
    final config = ApiConfig.instance.websocketConfig;
    final pingInterval = config['pingInterval'] as int;

    _pingTimer = Timer.periodic(
      Duration(milliseconds: pingInterval),
      (_) => _sendPing(),
    );
  }

  /// Send ping message
  void _sendPing() {
    _sendMessage({
      'type': 'ping',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    final config = ApiConfig.instance.websocketConfig;
    final maxAttempts = config['maxReconnectAttempts'] as int;
    final reconnectInterval = config['reconnectInterval'] as int;

    if (_reconnectAttempts >= maxAttempts) {
      TalkerConfig.logError('Max reconnection attempts reached');
      _eventController.add(WebSocketEvent.maxReconnectAttemptsReached());
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      milliseconds: reconnectInterval * _reconnectAttempts,
    );

    _reconnectTimer = Timer(delay, () {
      TalkerConfig.logInfo(
        'Attempting to reconnect WebSocket (attempt $_reconnectAttempts)',
      );
      connect();
    });
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _eventController.close();
    _subscribers.clear();
  }
}

/// WebSocket event types
class WebSocketEvent {
  final WebSocketEventType type;
  final String? message;
  final DateTime timestamp;

  WebSocketEvent._(this.type, this.message) : timestamp = DateTime.now();

  factory WebSocketEvent.connecting() =>
      WebSocketEvent._(WebSocketEventType.connecting, null);
  factory WebSocketEvent.connected() =>
      WebSocketEvent._(WebSocketEventType.connected, null);
  factory WebSocketEvent.disconnected() =>
      WebSocketEvent._(WebSocketEventType.disconnected, null);
  factory WebSocketEvent.error(String message) =>
      WebSocketEvent._(WebSocketEventType.error, message);
  factory WebSocketEvent.maxReconnectAttemptsReached() =>
      WebSocketEvent._(WebSocketEventType.maxReconnectAttemptsReached, null);

  @override
  String toString() {
    return 'WebSocketEvent(type: $type, message: $message, timestamp: $timestamp)';
  }
}

/// WebSocket event types
enum WebSocketEventType {
  connecting,
  connected,
  disconnected,
  error,
  maxReconnectAttemptsReached,
}
