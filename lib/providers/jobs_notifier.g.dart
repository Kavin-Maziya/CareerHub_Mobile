// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobsNotifier)
final jobsProvider = JobsNotifierProvider._();

final class JobsNotifierProvider
    extends $AsyncNotifierProvider<JobsNotifier, List<Job>> {
  JobsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobsNotifierHash();

  @$internal
  @override
  JobsNotifier create() => JobsNotifier();
}

String _$jobsNotifierHash() => r'9d3ab68a03646c511bea354468197a29e34bd863';

abstract class _$JobsNotifier extends $AsyncNotifier<List<Job>> {
  FutureOr<List<Job>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
              AsyncValue<List<Job>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
