import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: CareerHubApp()));
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
      // home: replaced by routerConfig
    );
  }
}