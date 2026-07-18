// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(applicationsRepository)
final applicationsRepositoryProvider = ApplicationsRepositoryProvider._();

final class ApplicationsRepositoryProvider
    extends
        $FunctionalProvider<
          ApplicationsRepository,
          ApplicationsRepository,
          ApplicationsRepository
        >
    with $Provider<ApplicationsRepository> {
  ApplicationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApplicationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApplicationsRepository create(Ref ref) {
    return applicationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplicationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplicationsRepository>(value),
    );
  }
}

String _$applicationsRepositoryHash() =>
    r'60b7057c9c8f746d58100916c9e5dd6492a6227a';
