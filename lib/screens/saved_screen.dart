
import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Center(
        child: Text(
          'Saved jobs will appear here.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}