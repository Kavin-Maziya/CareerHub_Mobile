import 'package:careerhub_mobile/core/prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_notifier.g.dart';

@riverpod
class FilterNotifier extends _$FilterNotifier {
  static const _key = 'selected_filter';

  @override
  String build() {
    final prefs = ref.watch(prefsProvider);
    return prefs.getString(_key) ?? 'All';
  }

  void select(String value) {
    final prefs = ref.read(prefsProvider);

    prefs.setString(_key, value);

    state = value;
  }
}