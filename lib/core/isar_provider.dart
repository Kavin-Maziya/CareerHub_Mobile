import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

final isarProvider = Provider<Isar>(
  (_) => throw UnimplementedError(
    'Isar has not been initialized. Override isarProvider in main.dart.',
  ),
);