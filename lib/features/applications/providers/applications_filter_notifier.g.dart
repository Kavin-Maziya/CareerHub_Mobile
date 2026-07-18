// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_filter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApplicationsFilterNotifier)
final applicationsFilterProvider = ApplicationsFilterNotifierProvider._();

final class ApplicationsFilterNotifierProvider
    extends $NotifierProvider<ApplicationsFilterNotifier, ApplicationStatus?> {
  ApplicationsFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationsFilterNotifierHash();

  @$internal
  @override
  ApplicationsFilterNotifier create() => ApplicationsFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplicationStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplicationStatus?>(value),
    );
  }
}

String _$applicationsFilterNotifierHash() =>
    r'5232b817ab6f65ebe2d3ff9f71aefc697b1402e1';

abstract class _$ApplicationsFilterNotifier
    extends $Notifier<ApplicationStatus?> {
  ApplicationStatus? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ApplicationStatus?, ApplicationStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApplicationStatus?, ApplicationStatus?>,
              ApplicationStatus?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
