import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';


final onUnauthenticatedProvider =
    Provider<void Function()>((ref) {

  return () {
    ref.invalidate(authProvider);
  };
});


class AuthStateListenable extends ChangeNotifier {

  AuthStateListenable(this.ref) {
    _subscription = ref.listen(
      authProvider,
      (_, _) {
        notifyListeners();
      },
    );
  }


  final Ref ref;

  late final ProviderSubscription _subscription;


  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}


final authStateListenableProvider =
    Provider<AuthStateListenable>((ref) {

  final listenable = AuthStateListenable(ref);

  ref.onDispose(
    listenable.dispose,
  );

  return listenable;
});