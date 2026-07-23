import 'package:careerhub_mobile/models/job.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:careerhub_mobile/providers/jobs_provider.dart';
import 'package:careerhub_mobile/providers/jobs_notifier.dart';
import 'package:careerhub_mobile/widgets/job_card.dart';
import 'package:careerhub_mobile/providers/filter_notifier.dart';
import 'package:careerhub_mobile/providers/connectivity_provider.dart';
import 'package:careerhub_mobile/providers/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // static const List<String> _filters = ['All', 'Remote', 'Full-Time'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // final jobsAsync = ref.watch(sortedJobsProvider);
    // final selectedFilter = ref.watch(filterProvider);
    // final sortOrder = ref.watch(sortOrderProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              ref.invalidate(jobsProvider);

              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            MaterialBanner(
              backgroundColor: theme.colorScheme.secondaryContainer,
              leading: const Icon(Icons.wifi_off),
              content: const Text('You are offline. Showing cached jobs.'),
              actions: const [],
            ),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilterChips(),
                Expanded(child: _JobList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  static const List<String> _filters = ['All', 'Remote', 'Full-Time'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // // ref.watch here -- this build() must rebuild whenever the filtered
    // // and sorted jobs value changes, whether that's a filter tap, a
    // // sort tap, or the underlying job list finishing its load.
    final selectedFilter = ref.watch(filterProvider);
    final sortOrder = ref.watch(sortOrderProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters
                  .map(
                    (label) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: label == selectedFilter,
                        onSelected: (_) {
                          ref.read(filterProvider.notifier).select(label);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Sort:', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('A–Z'),
                selected: sortOrder == 'A-Z',
                onSelected: (_) {
                  ref.read(sortOrderProvider.notifier).state = 'A-Z';
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Z–A'),
                selected: sortOrder == 'Z-A',
                onSelected: (_) {
                  ref.read(sortOrderProvider.notifier).state = 'Z-A';
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobList extends ConsumerWidget {
  const _JobList();
  // Shared by both the list and the grid -- takes the already-filtered
  // and sorted jobs list directly, since the data source is no longer
  // a field on this widget.

  Widget _buildCard(List<Job> jobs, int index) {
    return JobCard(job: jobs[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watches the filtered and sorted jobs only.
    final jobsAsync = ref.watch(sortedJobsProvider);

    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Something went wrong when loading jobs.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(jobsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (jobs) {
        // An empty filtered result with message, not a blank body.
        if (jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No jobs match this filter.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: jobs.length,
                itemBuilder: (context, index) => _buildCard(jobs, index),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: jobs.length,
              itemBuilder: (context, index) => _buildCard(jobs, index),
            );
          },
        );
      },
    );
  }
}
