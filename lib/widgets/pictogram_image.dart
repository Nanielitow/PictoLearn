import 'package:flutter/material.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/services/pictogram_image_service.dart';

/// Muestra el pictograma real de ARASAAC para [pictogram.word].
/// Mientras se busca/descarga la imagen, o si la búsqueda falla
/// (sin internet, palabra no encontrada), muestra el ícono de
/// respaldo definido en el modelo, para que el juego nunca se
/// quede con un espacio vacío.
class PictogramImage extends StatefulWidget {
  final Pictogram pictogram;

  const PictogramImage({super.key, required this.pictogram});

  @override
  State<PictogramImage> createState() => _PictogramImageState();
}

class _PictogramImageState extends State<PictogramImage> {
  late Future<String?> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = PictogramImageService.fetchImageUrl(widget.pictogram.word);
  }

  @override
  void didUpdateWidget(covariant PictogramImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pictogram.word != widget.pictogram.word) {
      _imageUrlFuture = PictogramImageService.fetchImageUrl(widget.pictogram.word);
    }
  }

  Widget _fallbackIcon() {
    return Icon(widget.pictogram.icon, size: 120, color: widget.pictogram.color);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: widget.pictogram.color,
              ),
            ),
          );
        }

        final url = snapshot.data;
        if (url == null) return _fallbackIcon();

        return Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  color: widget.pictogram.color,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      },
    );
  }
}
