import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talkerProvider = Provider<Talker>((ref) => TalkerFlutter.init());
