
import 'package:careerhub_mobile/core/isar_provider.dart';
import 'package:careerhub_mobile/core/prefs_provider.dart';
import 'package:careerhub_mobile/data/job_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [
      JobCacheSchema,
    ],
    directory: dir.path,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const CareerHubApp(),
    ),
  );
}

class CareerHubApp extends ConsumerWidget {
  const CareerHubApp({super.key});

  static const _seedColor = Color(0xFF183630);
  static const _gold = Color(0xFFE5C690);
  static const _cream = Color(0xFFE3DAC9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}