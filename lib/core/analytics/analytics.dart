import 'package:flutter/foundation.dart';

abstract class Analytics {
  Future<void> event(String name, {Map<String, Object?> params});
  Future<void> setUserId(String? id);
  Future<void> setUserProperty(String name, String? value);
}

class ConsoleAnalytics implements Analytics {
  @override
  Future<void> event(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    if (!kReleaseMode) debugPrint('ANALYTICS: $name $params');
  }

  @override
  Future<void> setUserId(String? id) async {
    if (!kReleaseMode) debugPrint('ANALYTICS: setUserId $id');
  }

  @override
  Future<void> setUserProperty(String n, String? v) async {
    if (!kReleaseMode) debugPrint('ANALYTICS: prop $n=$v');
  }
}
