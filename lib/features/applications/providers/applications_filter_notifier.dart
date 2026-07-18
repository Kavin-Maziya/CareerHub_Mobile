import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../main.dart' show sharedPreferencesProvider;
import '../models/application_status.dart';

part 'applications_filter_notifier.g.dart';

const _filterPrefsKey = 'applications_filter';

// null represents the "All" sentinel -- no specific status selected,
// show every application regardless of status.
@riverpod
class ApplicationsFilterNotifier extends _$ApplicationsFilterNotifier {
  @override
  ApplicationStatus? build() {
    // ref.watch here -- this is build(), not a mutation.
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_filterPrefsKey);
    if (stored == null || stored == 'All') return null;
    return ApplicationStatus.fromApiValue(stored);
  }

  // Mutation -- uses ref.read, not ref.watch
  void setFilter(ApplicationStatus? status) {
    final prefs = ref.read(sharedPreferencesProvider);
    // Fire-and-forget the disk write -- state updates immediately below
    // regardless of when the write actually completes, since the prefs
    // plugin caches the value in memory synchronously on this call.
    unawaited(prefs.setString(_filterPrefsKey, _toPrefsValue(status)));
    state = status;
  }

  String _toPrefsValue(ApplicationStatus? status) => switch (status) {
        null => 'All',
        ApplicationStatus.submitted => 'Submitted',
        ApplicationStatus.underReview => 'UnderReview',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.offered => 'Offered',
        ApplicationStatus.rejected => 'Rejected',
      };
}