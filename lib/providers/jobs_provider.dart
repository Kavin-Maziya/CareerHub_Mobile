
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/job.dart';
import 'jobs_notifier.dart';
import 'filter_notifier.dart';


final sortOrderProvider = StateProvider<String>((ref) => 'A-Z');

// filteredJobsProvider
// Derived state. Watches the real jobsProvider (from jobs_notifier.dart,
// backed by the repository/API) and the filter. Recomputes automatically
// whenever either changes.

// Converted to a switch expression with guard clauses
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);

final filter = ref.watch(filterNotifierProvider);

  return asyncJobs.whenData((jobs) {
    return switch (filter) {
  'All' => jobs,
  'Remote' => jobs.where((j) => j.location == 'Remote').toList(),
  _ when filter.isNotEmpty =>
    jobs.where((j) => j.employmentType.displayName == filter).toList(),
  _ => jobs,
};
  });
});

final sortedJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final filteredAsync = ref.watch(filteredJobsProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  return filteredAsync.whenData((jobs) {
    final sorted = List<Job>.from(jobs);
    sorted.sort((a, b) => sortOrder == 'A-Z'
        ? a.title.compareTo(b.title)
        : b.title.compareTo(a.title));
    return sorted;
  });
});