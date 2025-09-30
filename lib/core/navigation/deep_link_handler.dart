import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../logging/talker_config.dart';

/// Deep link handler for URL navigation
///
/// Usage:
/// ```dart
/// final handler = DeepLinkHandler(router);
/// await handler.initialize();
/// ```
class DeepLinkHandler {
  final GoRouter _router;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkHandler(this._router);

  /// Initialize deep link handling
  Future<void> initialize() async {
    try {
      // Handle initial link
      await _handleInitialLink();

      // Handle incoming links
      _handleIncomingLinks();

      TalkerConfig.logInfo('Deep link handler initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize deep link handler',
        e,
        stackTrace,
      );
    }
  }

  /// Handle initial link when app is opened
  Future<void> _handleInitialLink() async {
    try {
      // This would be implemented with app_links package in real app
      // For now, we'll just log that it's ready
      TalkerConfig.logInfo(
        'Deep link handler ready for initial link processing',
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to handle initial link', e, stackTrace);
    }
  }

  /// Handle incoming links
  void _handleIncomingLinks() {
    // This would be implemented with app_links package in real app
    // For now, we'll just log that it's ready
    TalkerConfig.logInfo(
      'Deep link handler ready for incoming link processing',
    );
  }

  /// Navigate to specific route
  Future<void> navigateToRoute(
    String route, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(route);
      final location = _buildLocation(uri, queryParams);

      TalkerConfig.logInfo('Navigating to deep link: $location');

      try {
        _router.go(location);
      } catch (e) {
        // If router is not ready, wait a bit and try again
        Timer(const Duration(milliseconds: 100), () {
          try {
            _router.go(location);
          } catch (e) {
            TalkerConfig.logError('Failed to navigate to route: $location', e);
          }
        });
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to navigate to route: $route',
        e,
        stackTrace,
      );
    }
  }

  /// Build location from URI and query parameters
  String _buildLocation(Uri uri, Map<String, String>? queryParams) {
    var location = uri.path;

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      location = '$location?$queryString';
    }

    return location;
  }

  /// Handle specific deep link patterns
  Future<void> handleDeepLink(String link) async {
    try {
      final uri = Uri.parse(link);
      TalkerConfig.logInfo('Handling deep link: $link');

      switch (uri.host) {
        case 'sales':
          await _handleSalesDeepLink(uri);
          break;
        case 'inventory':
          await _handleInventoryDeepLink(uri);
          break;
        case 'products':
          await _handleProductsDeepLink(uri);
          break;
        case 'customers':
          await _handleCustomersDeepLink(uri);
          break;
        case 'payments':
          await _handlePaymentsDeepLink(uri);
          break;
        default:
          await _handleDefaultDeepLink(uri);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to handle deep link: $link', e, stackTrace);
    }
  }

  /// Handle sales deep links
  Future<void> _handleSalesDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      await navigateToRoute('/sales');
    } else if (pathSegments.length == 1) {
      final saleId = pathSegments[0];
      await navigateToRoute('/sales/$saleId');
    } else if (pathSegments.length == 2) {
      final action = pathSegments[0];
      final id = pathSegments[1];

      switch (action) {
        case 'view':
          await navigateToRoute('/sales/$id');
          break;
        case 'edit':
          await navigateToRoute('/sales/$id/edit');
          break;
        default:
          await navigateToRoute('/sales');
      }
    }
  }

  /// Handle inventory deep links
  Future<void> _handleInventoryDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      await navigateToRoute('/inventory');
    } else if (pathSegments.length == 1) {
      final itemId = pathSegments[0];
      await navigateToRoute('/inventory/$itemId');
    } else if (pathSegments.length == 2) {
      final action = pathSegments[0];
      final id = pathSegments[1];

      switch (action) {
        case 'view':
          await navigateToRoute('/inventory/$id');
          break;
        case 'edit':
          await navigateToRoute('/inventory/$id/edit');
          break;
        case 'add':
          await navigateToRoute('/inventory/add');
          break;
        default:
          await navigateToRoute('/inventory');
      }
    }
  }

  /// Handle products deep links
  Future<void> _handleProductsDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      await navigateToRoute('/products');
    } else if (pathSegments.length == 1) {
      final productId = pathSegments[0];
      await navigateToRoute('/products/$productId');
    }
  }

  /// Handle customers deep links
  Future<void> _handleCustomersDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      await navigateToRoute('/customers');
    } else if (pathSegments.length == 1) {
      final customerId = pathSegments[0];
      await navigateToRoute('/customers/$customerId');
    }
  }

  /// Handle payments deep links
  Future<void> _handlePaymentsDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      await navigateToRoute('/payments');
    } else if (pathSegments.length == 1) {
      final paymentId = pathSegments[0];
      await navigateToRoute('/payments/$paymentId');
    }
  }

  /// Handle default deep links
  Future<void> _handleDefaultDeepLink(Uri uri) async {
    TalkerConfig.logInfo('Handling default deep link: ${uri.toString()}');
    await navigateToRoute('/');
  }

  /// Generate deep link for specific content
  String generateDeepLink(String type, String id, {String? action}) {
    final baseUrl = kDebugMode
        ? 'https://dev.modaapp.com'
        : 'https://modaapp.com';

    if (action != null) {
      return '$baseUrl/$type/$action/$id';
    } else {
      return '$baseUrl/$type/$id';
    }
  }

  /// Share deep link
  Future<void> shareDeepLink(String type, String id, {String? action}) async {
    try {
      final deepLink = generateDeepLink(type, id, action: action);
      TalkerConfig.logInfo('Generated deep link: $deepLink');

      // TODO: Implement sharing functionality
      // This would use share_plus package in real app
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to share deep link', e, stackTrace);
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
