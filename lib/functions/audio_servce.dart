import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AudioService {
  final FlutterTts flutterTts = FlutterTts();
  final VolumeController _volumeController = VolumeController.instance;

  bool _isSpeaking = false;

Future<void> audioPlay(String textToSpeak) async {
  if (_isSpeaking) {
    debugPrint("🔇 Ya se está reproduciendo un audio TTS.");
    return;
  }

  _isSpeaking = true;
  double? originalVolume;

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool autoMaxVolume = prefs.getBool('autoMaxVolume') ?? true;
    double speechRate = prefs.getDouble('speechRate') ?? 0.5;

    originalVolume = await _volumeController.getVolume();
    if (autoMaxVolume) await _volumeController.setVolume(1.0);

    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setVolume(1.0);

    final completer = Completer<void>();

    flutterTts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });

    flutterTts.setErrorHandler((msg) {
      if (!completer.isCompleted) completer.completeError(Exception(msg));
    });

    await flutterTts.speak(textToSpeak);

    // Esperar hasta que termine TTS, pero con timeout seguro
    await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        debugPrint('⚠️ TTS timeout, se detiene reproducción');
        flutterTts.stop();
        return null; // No lanza excepción, simplemente termina
      },
    );

  } catch (e) {
    debugPrint('⚠️ Error en audioPlay: $e');
    await flutterTts.stop();
  } finally {
    if (originalVolume != null) await _volumeController.setVolume(originalVolume);
    _isSpeaking = false;
  }
}

}