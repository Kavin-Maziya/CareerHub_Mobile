import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/api_result.dart';
import '../data/applications_repository.dart';
import '../models/job_application.dart';

part 'applications_notifier.g.dart';

@riverpod
class ApplicationsNotifier extends _$ApplicationsNotifier {
  @override
  Future<List<JobApplication>> build() async {
    final repository = ref.read(applicationsRepositoryProvider);

    // Cache-then-network: read Isar first.
    final cached = await repository.getCachedApplications();

    if (cached.isNotEmpty) {
      // Assign immediately so the UI responds before the network request completes.
      state = AsyncData(cached);
    }

    final result = await repository.fetchAndCacheApplications();

    return switch (result) {
      Success(:final data) => data,
      // Cache is empty and the network also failed -- nothing to show,
      // so this is a genuine error.
      Failure(:final message) when cached.isEmpty => throw Exception(message),
      // Network failed, but the cache has data -- show it, not an
      // error screen.
      Failure() => cached,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}