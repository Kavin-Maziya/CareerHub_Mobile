import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'SharedPreferences has not been initialized. Override prefsProvider in main.dart.',
  ),
);