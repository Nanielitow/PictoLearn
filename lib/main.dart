import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:pictolearn/pages/login.dart';
import 'package:pictolearn/pages/home.dart';
import 'package:pictolearn/pages/register.dart';
import 'package:pictolearn/pages/juegoRompecabezas.dart';
import 'package:pictolearn/services/go_router_refresh_stream.dart';
import 'package:pictolearn/firebase_options.dart';
import 'package:pictolearn/pages/matchGame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),
      redirect: (context, state) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final isGoingToAuthPages =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // Si no hay sesión y trata de entrar a una pantalla protegida,
        // lo mandamos a login.
        if (!isLoggedIn && !isGoingToAuthPages) {
          return '/login';
        }

        // Si ya inició sesión y trata de volver a login/register,
        // lo mandamos directo a home.
        if (isLoggedIn && isGoingToAuthPages) {
          return '/home';
        }

        // En cualquier otro caso, no redirigimos.
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Login()
          ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Home()
          ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()
          ),
        GoRoute(
          path: '/juegoRompecabezas',
          builder: (context, state) => GameScreen()
          ),
        GoRoute(
          path: '/juegoEmparejar',
          builder: (context, state) => const MatchGameScreen()
          ),
        ]
      );

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}