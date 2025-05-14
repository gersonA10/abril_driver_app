import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> audioPlay(String textToSpeak) async {
    await flutterTts.setLanguage("es-ES");  // Configura el idioma español
    await flutterTts.setPitch(1.0);  // Configura el tono
    await flutterTts.setSpeechRate(0.5);  // Configura la velocidad del habla
    
    // Reproduce el texto solo una vez
    await flutterTts.speak(textToSpeak);
  }
}
