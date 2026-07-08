// Extracted out of JobCard because
// it has one clear job (display status),
// To be reused elsewhere in the App (employer dashboards, application tracking),
// and it can be tested completely on its own without needing a full Job.
// Purely presentational — no business logic lives here. 
// Colours come from the theme, adapts automatically in light and dark mode.

import 'package:flutter/material.dart';

class JobStatusBadge extends StatelessWidget {
  final bool isOpen;

  const JobStatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isOpen
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}