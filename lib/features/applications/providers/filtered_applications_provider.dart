import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_application.dart';
import 'applications_notifier.dart';
import 'applications_filter_notifier.dart';

// Derived state -- watches both the applications notifier and the
// filter notifier. Widgets watch ONLY this provider, never the raw
// applications notifier directly.

final filteredApplicationsProvider =
    Provider<AsyncValue<List<JobApplication>>>((ref) {
  final asyncApplications = ref.watch(applicationsProvider);
  final filter = ref.watch(applicationsFilterProvider);

  return asyncApplications.whenData((applications) {
    if (filter == null) return applications;
    return applications.where((a) => a.status == filter).toList();
  });
});