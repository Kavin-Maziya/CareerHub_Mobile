import 'package:flutter/material.dart';
import '../models/application_status.dart';

// Extracted, standalone widget. Uses a switch expression to map every
// ApplicationStatus value to a distinct M3 colour role -- exhaustive by
// construction, so a missing case is a compile-time error, not a
// runtime fallback.
class ApplicationStatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const ApplicationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (background, foreground) = switch (status) {
      ApplicationStatus.submitted => (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
        ),
      ApplicationStatus.underReview => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        ),
      ApplicationStatus.shortlisted => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
      ApplicationStatus.offered => (
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
        ),
      ApplicationStatus.rejected => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}