import 'dart:async';
import 'package:flutter/material.dart';
import '../logging/talker_config.dart';

/// Advanced animation service for modern UI/UX
///
/// Usage:
/// ```dart
/// final animationService = AnimationService();
/// await animationService.initialize();
/// final controller = animationService.createFadeController();
/// ```
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  final Map<String, AnimationController> _controllers = {};
  final Map<String, AnimationController> _riveControllers = {};
  bool _isInitialized = false;

  /// Initialize animation service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Preload common animations
      await _preloadAnimations();

      _isInitialized = true;
      TalkerConfig.logInfo('Animation service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize animation service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Preload common animations
  Future<void> _preloadAnimations() async {
    try {
      // Preload Lottie animations
      // await Lottie.asset('assets/animations/loading.json');
      // await Lottie.asset('assets/animations/success.json');
      // await Lottie.asset('assets/animations/error.json');

      TalkerConfig.logInfo('Animations preloaded');
    } catch (e) {
      TalkerConfig.logWarning('Failed to preload some animations: $e');
    }
  }

  /// Create fade animation controller
  AnimationController createFadeController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    String? key,
  }) {
    final controllerKey =
        key ?? 'fade_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create slide animation controller
  AnimationController createSlideController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    String? key,
  }) {
    final controllerKey =
        key ?? 'slide_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create scale animation controller
  AnimationController createScaleController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 200),
    String? key,
  }) {
    final controllerKey =
        key ?? 'scale_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create rotation animation controller
  AnimationController createRotationController({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    String? key,
  }) {
    final controllerKey =
        key ?? 'rotation_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create bounce animation controller
  AnimationController createBounceController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    String? key,
  }) {
    final controllerKey =
        key ?? 'bounce_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create shimmer animation controller
  AnimationController createShimmerController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1500),
    String? key,
  }) {
    final controllerKey =
        key ?? 'shimmer_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create staggered animation controller
  AnimationController createStaggeredController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    String? key,
  }) {
    final controllerKey =
        key ?? 'staggered_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(duration: duration, vsync: vsync);

    _controllers[controllerKey] = controller;
    return controller;
  }

  /// Create Rive animation controller (simplified)
  AnimationController createRiveController({
    required TickerProvider vsync,
    String? key,
  }) {
    final controllerKey =
        key ?? 'rive_${DateTime.now().millisecondsSinceEpoch}';

    final controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    _riveControllers[controllerKey] = controller;
    return controller;
  }

  /// Create custom animation curve
  Curve createCustomCurve({
    double? firstControlPointX,
    double? firstControlPointY,
    double? secondControlPointX,
    double? secondControlPointY,
  }) {
    return Cubic(
      firstControlPointX ?? 0.25,
      firstControlPointY ?? 0.1,
      secondControlPointX ?? 0.25,
      secondControlPointY ?? 1.0,
    );
  }

  /// Create spring animation
  SpringDescription createSpring({
    double mass = 1.0,
    double stiffness = 100.0,
    double damping = 10.0,
  }) {
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }

  /// Animate widget with custom animation
  Widget animateWidget({
    required Widget child,
    required AnimationController controller,
    required Animation<double> animation,
    Curve curve = Curves.easeInOut,
    Duration delay = Duration.zero,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..scaleByDouble(
              animation.value,
              animation.value,
              animation.value,
              1.0,
            )
            ..translateByDouble(0.0, (1 - animation.value) * 50, 0.0, 0.0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }

  /// Create staggered list animation
  List<AnimationController> createStaggeredListControllers({
    required TickerProvider vsync,
    required int itemCount,
    Duration duration = const Duration(milliseconds: 300),
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final controllers = <AnimationController>[];

    for (int i = 0; i < itemCount; i++) {
      final controller = AnimationController(duration: duration, vsync: vsync);

      // Stagger the start time
      Timer(Duration(milliseconds: i * staggerDelay.inMilliseconds), () {
        controller.forward();
      });

      controllers.add(controller);
      _controllers['staggered_$i'] = controller;
    }

    return controllers;
  }

  /// Create loading animation
  Widget createLoadingAnimation({double size = 24.0, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }

  /// Create success animation
  Widget createSuccessAnimation({double size = 48.0, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 24.0),
    );
  }

  /// Create error animation
  Widget createErrorAnimation({double size = 48.0, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, color: Colors.white, size: 24.0),
    );
  }

  /// Create shimmer effect
  Widget createShimmerEffect({
    required Widget child,
    required AnimationController controller,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey, Colors.white, Colors.grey],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Create page transition
  Widget createPageTransition({
    required Widget child,
    required Animation<double> animation,
    PageTransitionType type = PageTransitionType.fade,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(scale: animation, child: child);
      case PageTransitionType.rotation:
        return RotationTransition(turns: animation, child: child);
    }
  }

  /// Dispose controller
  void disposeController(String key) {
    final controller = _controllers[key];
    if (controller != null) {
      controller.dispose();
      _controllers.remove(key);
    }
  }

  /// Dispose all controllers
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _riveControllers.clear();
  }

  /// Get controller by key
  AnimationController? getController(String key) {
    return _controllers[key];
  }

  /// Get Rive controller by key
  AnimationController? getRiveController(String key) {
    return _riveControllers[key];
  }
}

/// Page transition types
enum PageTransitionType { fade, slide, scale, rotation }

/// Animation presets
class AnimationPresets {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}
