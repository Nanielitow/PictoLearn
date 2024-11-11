import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pictolearn/pages/login.dart';
import 'package:pictolearn/pages/home.dart';
import 'package:pictolearn/pages/register.dart';


void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(initialLocation: '/login', routes: [
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
        ]
      ),
    );
  }
}


