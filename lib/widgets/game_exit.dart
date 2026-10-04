import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pictolearn/theme/app_colors.dart';

/// Pregunta "¿Salir del juego?" y, si el niño confirma, vuelve a /home.
/// [message] es el texto de resumen (ej. "Acertaste 3 de 5 palabras").
Future<void> confirmExitGame(
  BuildContext context, {
  required String message,
}) async {
  final exit = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('¿Salir del juego? 👋'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Seguir jugando'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Salir', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (exit == true && context.mounted) context.go('/home');
}

/// Envuelve la pantalla de un juego para que el botón "atrás" del sistema
/// llame a [onExitRequested] (normalmente [confirmExitGame]) en vez de salir.
class GameExitScope extends StatelessWidget {
  final Widget child;
  final VoidCallback onExitRequested;

  const GameExitScope({
    super.key,
    required this.child,
    required this.onExitRequested,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onExitRequested();
      },
      child: child,
    );
  }
}
