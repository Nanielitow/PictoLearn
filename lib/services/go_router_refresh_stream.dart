import 'dart:async';
import 'package:flutter/foundation.dart';

/// Convierte cualquier Stream en un Listenable, para que go_router
/// pueda "escuchar" cambios de sesión (authStateChanges) y recalcular
/// el redirect automáticamente cada vez que el usuario inicia o
/// cierra sesión, sin tener que navegar manualmente.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}