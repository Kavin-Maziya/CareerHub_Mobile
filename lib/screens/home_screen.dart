
import 'package:careerhub_mobile/models/job.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:careerhub_mobile/providers/jobs_provider.dart';
import 'package:careerhub_mobile/widgets/job_card.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<String> _filters = ['All', 'Remote', 'Full-Time'];

  // Shared by both the list and the grid -- takes the already-filtered
  // jobs list directly, since the data source is no longer a field on
  // this widget.
  Widget _buildCard(BuildContext context, List<Job> jobs, int index) {
    return JobCard(job: jobs[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // ref.watch here -- this build() must rebuild whenever the filtered
    // jobs value changes, whether that's a filter tap or the underlying
    // job list finishing its load.
    final filteredJobsAsync = ref.watch(filteredJobsProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Filter chip row stays pinned above the list or grid,
          // no matter which AsyncValue state is showing below it.
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
                          // Selection is driven by the provider value,
                          // not local widget state.
                          selected: label == selectedFilter,
                          onSelected: (_) {
                            // ref.read here -- this is a callback, not
                            // build(). We're updating state once in
                            // response to a tap, not subscribing to it.
                            ref.read(selectedFilterProvider.notifier).state =
                                label;
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          Expanded(
            child: filteredJobsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                        'Something went wrong loading jobs.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(jobsProvider),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) =>
                            _buildCard(context, jobs, index),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) =>
                          _buildCard(context, jobs, index),
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