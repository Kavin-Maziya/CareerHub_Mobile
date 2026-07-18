import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StreamProvider wrapping the connectivity stream -- no polling, no
// Timer, per the "things to remember" instruction.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => Connectivity().onConnectivityChanged,
);

// Derived Provider<bool> -- true when the device has no active
// connection. Defaults to "online" while the stream's first event
// hasn't arrived yet, so the banner doesn't flash on briefly during
// startup.
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.maybeWhen(
    data: (results) =>
        results.isEmpty || results.every((r) => r == ConnectivityResult.none),
    orElse: () => false,
  );
});