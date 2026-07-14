import 'package:careerhub_mobile/data/jobs_repository.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'jobs_notifier.g.dart';

@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  Future<List<Job>> build() async {
    return ref.read(jobsRepositoryProvider).getJobs();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}