import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import 'package:flutter_riverpod/legacy.dart';


final _allJobs = <Job>[
  Job(
    id: 1,
    title: 'Senior Frontend Software Engineer',
    company: 'TechCorp Cape Town',
    location: 'Cape Town',
    description: 'We are looking for a talented Senior Frontend Engineer...',
    employmentType: 'Full-Time',
    isOpen: true,
    salary: 37500,
    closingDate: DateTime(2026, 7, 24),
  ),
  Job(
    id: 2,
    title: 'UX/Web Designer',
    company: 'DesignHouse Sandton',
    location: 'Sandton',
    description: 'We are looking for a creative UX/Web Designer...',
    employmentType: 'Contract',
    isOpen: true,
  ),
  Job.closed(
    id: 3,
    title: 'Data Analyst Intern',
    company: 'DataWorks Pretoria',
    location: 'Pretoria/Hybrid',
    description: 'We are looking for a Data Analyst Intern...',
    employmentType: 'Internship',
    salary: 18500,
    closingDate: DateTime(2026, 6, 19),
  ),
  Job.remote(
    id: 4,
    title: 'Part-Time Content Writer/Promoter',
    company: 'MediaCo',
    description: 'We are looking for a Content Writer...',
    employmentType: 'Part-Time',
    isOpen: true,
    salary: 15000,
    closingDate: DateTime(2026, 7, 24),
  ),
];

// jobsProvider
// AsyncNotifier simulates a network round-trip.
// The delay must be visible to the user -- at
// least one second of loading state before the list appears.

class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _allJobs;
  }
}

final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(
  JobsNotifier.new,
);

// selectedFilterProvider
// Holds the currently selected filter chip label. Default filter is 'All'.
final selectedFilterProvider = StateProvider<String>((ref) => 'All');
final sortOrderProvider = StateProvider<String>((ref) => 'A-Z');

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

// filteredJobsProvider
// Derived state. Watches both providers above. Recomputes automatically
// whenever either changes -- the widget never manually syncs these two
// values itself.
final filteredJobsProvider = Provider<AsyncValue<List<Job>>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final filter = ref.watch(selectedFilterProvider);

  // whenData only runs the transform when jobs are loaded.
  // Loading and error states pass through unchanged.
  return asyncJobs.whenData((jobs) {
    if (filter == 'All') return jobs;
    if (filter == 'Remote') {
      return jobs.where((j) => j.location == 'Remote').toList();
    }
    // Matches the employmentType field directly -- e.g. 'Full-Time'.
    return jobs.where((j) => j.employmentType == filter).toList();
  });
});