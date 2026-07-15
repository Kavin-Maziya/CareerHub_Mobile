import 'package:careerhub_mobile/data/jobs_repository.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:careerhub_mobile/data/api_result.dart';

part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  Future<List<Job>> build() async {
    final result = await ref.read(jobsRepositoryProvider).getJobs();

    // Exhaustive switch -- the compiler enforces both arms are handled,
    // since ApiResult is sealed and Success/Failure are its only two
    // possible subclasses.
    return switch (result) {
      Success(:final data) => data,
      Failure(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}