import 'package:careerhub_mobile/data/jobs_repository.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:careerhub_mobile/data/api_result.dart';

part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  
  @override
Future<List<Job>> build() async {
  final repository = ref.read(jobsRepositoryProvider);

  // Step 1: Load cached jobs first.
  final cachedJobs = await repository.getCachedJobs();

  // Step 2: Surface the cache immediately while the network request runs.
  if (cachedJobs.isNotEmpty) {
    state = AsyncData(cachedJobs);
  }

  // Step 3: Fetch the latest jobs from the API.
  final result = await repository.getJobs();

  // Step 4: Prefer fresh data, otherwise fall back to cache.
  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) =>
      cachedJobs.isNotEmpty
          ? cachedJobs
          : throw Exception(message),
  };
}

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}