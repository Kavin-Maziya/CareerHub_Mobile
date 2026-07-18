import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_status.dart';
import '../models/job_application.dart';
import '../providers/applications_filter_notifier.dart';
import '../providers/applications_notifier.dart';
import '../providers/filtered_applications_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/application_card.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  Widget _buildCard(BuildContext context, List<JobApplication> apps, int i) {
    return ApplicationCard(application: apps[i]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applicationsAsync = ref.watch(filteredApplicationsProvider);
    final selectedFilter = ref.watch(applicationsFilterProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Offline banner -- appears/disappears automatically, driven
          // by the connectivity stream. No tap required.
          if (isOffline)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.cloud_off,
                      size: 18, color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    'You\'re offline. Showing cached applications.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ],
              ),
            ),

          // Filter chip row: one per ApplicationStatus, plus "All".
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: selectedFilter == null,
                      onSelected: (_) => ref
                          .read(applicationsFilterProvider.notifier)
                          .setFilter(null),
                    ),
                  ),
                  ...ApplicationStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.displayLabel),
                        selected: selectedFilter == status,
                        onSelected: (_) => ref
                            .read(applicationsFilterProvider.notifier)
                            .setFilter(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: applicationsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load applications.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(applicationsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return Center(
                    child: Text(
                      'No applications match this filter.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;

                    if (isWide) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: apps.length,
                        itemBuilder: (context, i) =>
                            _buildCard(context, apps, i),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: apps.length,
                      itemBuilder: (context, i) =>
                          _buildCard(context, apps, i),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}