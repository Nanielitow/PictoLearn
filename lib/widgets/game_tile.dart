import 'package:flutter/material.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/widgets/pictogram_image.dart';

/// Tarjeta blanca redondeada con borde de feedback (verde/rojo/azul).
/// Es la "casilla" estándar que usan los juegos para mostrar pictogramas.
class GameTile extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color fillColor;
  final VoidCallback? onTap;

  const GameTile({
    super.key,
    required this.child,
    this.borderColor = Colors.transparent,
    this.fillColor = Colors.white,
    this.onTap,
  });

  static const Color _shadowColor = Color(0x402196F3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: const [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Imagen del pictograma que llena su tarjeta; el ícono de respaldo
/// escala con el tamaño disponible.
class GameTileImage extends StatelessWidget {
  final Pictogram pictogram;

  const GameTileImage({super.key, required this.pictogram});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return SizedBox.expand(
          child: PictogramImage(
            pictogram: pictogram,
            fallbackIconSize: side.isFinite ? side * 0.7 : 80,
          ),
        );
      },
    );
  }
}