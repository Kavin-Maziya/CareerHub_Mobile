import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Connectivity _connectivity = Connectivity();


final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return _connectivity.onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).when(
    data: (results) =>
        results.every((result) => result == ConnectivityResult.none),
    loading: () => false,
    error: (_, _) => false,
  );
});