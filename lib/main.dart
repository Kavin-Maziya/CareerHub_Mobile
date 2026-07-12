import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: CareerHubApp()));
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  static const _seedColor = Color(0xFF0D3B36); // deep teal
  static const _gold = Color(0xFFE5C690);
  static const _cream = Color(0xFFE3DAC9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ).copyWith(
          secondary: _gold,
          surfaceContainerHighest: _cream,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: _gold,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}


// import 'package:careerhub_mobile/screens/home_screen.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const CareerHubApp());
// }

// class CareerHubApp extends StatelessWidget {
//   const CareerHubApp({super.key});

// static const _seedColor = Color(0xFF0D3B36); // custom deep teal

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CareerHub',
//       theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: _seedColor), 
//           brightness: Brightness.light,
//         useMaterial3: true,
//       ), 
//       darkTheme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: _seedColor,
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//       ),
//       themeMode: ThemeMode.system, //System aware Theme Mode
//       home: const HomeScreen(),
//     );
//   }
// }