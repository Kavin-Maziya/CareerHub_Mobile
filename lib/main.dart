// lib/main.dart

import 'package:careerhub_mobile/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CareerHubApp());
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

static const _seedColor = Color(0xFF0D3B36); // custom deep teal

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerHub',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: _seedColor), 
          brightness: Brightness.light,
        useMaterial3: true,
      ), 
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, //System aware Theme Mode
      home: const HomeScreen(),
    );
  }
}