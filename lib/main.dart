
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';
import 'features/applications/data/application_cache_entry.dart';


final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main()');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main()');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ApplicationCacheEntrySchema],
    directory: dir.path,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CareerHubApp(),
    ),
  );
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  static const _seedColor = Color(0xFF183630);
  static const _gold = Color(0xFFE5C690);
  static const _cream = Color(0xFFE3DAC9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareerHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ).copyWith(secondary: _gold, surfaceContainerHighest: _cream),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ).copyWith(secondary: _gold),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}