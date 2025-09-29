import 'package:flutter/material.dart';
import 'package:deneme1/core/utils/responsive.dart';

/// Context extensions for common operations
///
/// Usage:
/// ```dart
/// final isMobile = context.isMobile;
/// final theme = context.theme;
/// ```
extension ContextExtensions on BuildContext {
  /// Get current theme
  ThemeData get theme => Theme.of(this);

  /// Get current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get current media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is mobile
  bool get isMobile => Responsive.isMobile(this);

  /// Check if device is tablet
  bool get isTablet => Responsive.isTablet(this);

  /// Check if device is desktop
  bool get isDesktop => Responsive.isDesktop(this);

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Get view insets
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get status bar height
  double get statusBarHeight => safeAreaPadding.top;

  /// Get bottom safe area height
  double get bottomSafeAreaHeight => safeAreaPadding.bottom;

  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.primary);
  }

  /// Navigate to page
  Future<T?> navigateTo<T>(Widget page) {
    return Navigator.of(
      this,
    ).push<T>(MaterialPageRoute(builder: (context) => page));
  }

  /// Navigate and replace
  Future<T?> navigateAndReplace<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigate and clear stack
  Future<T?> navigateAndClearStack<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Pop current page
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();
}
