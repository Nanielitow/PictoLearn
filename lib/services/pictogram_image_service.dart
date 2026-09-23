import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio que busca pictogramas reales (diseñados para niños y
/// comunicación aumentativa) en la API pública y gratuita de ARASAAC
/// (Gobierno de Aragón, España) — https://arasaac.org
///
/// Uso: dado el nombre en inglés de un pictograma (ej. "cat"), busca
/// su imagen real y devuelve la URL para mostrarla con Image.network.
///
/// Los resultados se guardan en caché en memoria durante la sesión,
/// para no repetir la búsqueda cada vez que aparece la misma palabra.
class PictogramImageService {
  static final Map<String, String?> _cache = {};

  /// Devuelve la URL de la imagen del pictograma para [word], o null
  /// si no se encontró ninguno o falló la conexión (en cuyo caso la
  /// UI debe mostrar un ícono de respaldo).
  static Future<String?> fetchImageUrl(String word) async {
    final key = word.toLowerCase().trim();

    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final searchUri = Uri.parse(
        'https://api.arasaac.org/api/pictograms/en/bestsearch/$key',
      );
      final response = await http
          .get(searchUri)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          final id = results.first['_id'];
          // 500px es un buen tamaño para tarjetas grandes sin pesar demasiado.
          final imageUrl = 'https://static.arasaac.org/pictograms/$id/${id}_500.png';
          _cache[key] = imageUrl;
          return imageUrl;
        }
      }
    } catch (_) {
      // Sin conexión, timeout, o palabra no encontrada: se cachea como
      // null para no reintentar en cada frame, y la UI usa el ícono.
    }

    _cache[key] = null;
    return null;
  }
}