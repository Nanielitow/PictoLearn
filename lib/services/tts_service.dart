import 'package:flutter_tts/flutter_tts.dart';

/// Envuelve [FlutterTts] con la configuración de voz de PictoLearn
/// (español, tono infantil) para no repetirla en cada juego.
///
/// Uso típico dentro de un State:
/// ```dart
/// final _tts = TtsService();            // en el campo
/// _tts.speak(pictogram.translation);    // para hablar
/// _tts.stop();                          // en dispose()
/// ```
class TtsService {
  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;

  TtsService({
    String language = 'es-ES',
    double speechRate = 0.5,
    double pitch = 1.1,
  }) {
    _ready = _configure(language, speechRate, pitch);
  }

  Future<void> _configure(String language, double rate, double pitch) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
  }

  /// Corta lo que se esté diciendo y dice [text]. Espera a que la
  /// configuración inicial termine para no hablar con la voz por defecto.
  Future<void> speak(String text) async {
    await _ready;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
