import 'package:careerhub_mobile/models/employment_type.dart';
import 'package:careerhub_mobile/providers/jobs_notifier.dart';
import 'package:careerhub_mobile/widgets/job_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId; // changed from int -- Job.id is now a String (Guid)

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watching the raw, unfiltered jobsProvider -- not filteredJobsProvider
    // or sortedJobsProvider -- because a job reached via a direct URL
    // (deep link, notification tap) must resolve correctly regardless of
    // whatever filter or sort the Jobs tab happens to be in at that moment.
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  'Something went wrong loading this job.',
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
          final job = jobs.where((j) => j.id == jobId).firstOrNull;

          // Invalid ID -- handled gracefully, not with a crash.
          if (job == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 48, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'This job could not be found.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    JobStatusBadge(isOpen: job.canApply),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.company,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                _DetailRow(icon: Icons.location_on_outlined, label: job.location),
                _DetailRow(icon: Icons.work_outline, label: EmploymentType.fromApiValue(job.employmentType).displayName,),
                _DetailRow(icon: Icons.payments_outlined, label: job.displaySalary),
                if (job.closingDate != null)
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: job.canApply
                        ? 'Closes: ${_formatDate(job.closingDate!)}'
                        : 'Closed on: ${_formatDate(job.closingDate!)}',
                  ),

                const SizedBox(height: 24),
                Text('Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(job.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}