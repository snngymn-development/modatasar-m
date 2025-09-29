import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RemoteConfigService {
  final Map<String, dynamic> _defaults;
  RemoteConfigService(this._defaults);

  Future<Map<String, dynamic>> loadLocalDefaults() async {
    try {
      final s = await rootBundle.loadString('assets/config/default_flags.json');
      final m = jsonDecode(s) as Map<String, dynamic>;
      return {..._defaults, ...m};
    } catch (_) {
      return {..._defaults};
    }
  }

  bool flag(Map<String, dynamic> cfg, String key, {bool fallback = false}) {
    final v = cfg[key];
    return v is bool ? v : fallback;
  }
}
