import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechProvider with ChangeNotifier {
  double _speechRate = 0.5;
  final FlutterTts _flutterTts = FlutterTts();

  double get speechRate => _speechRate;
  FlutterTts get flutterTts => _flutterTts;

  SpeechProvider() {
    _loadSpeechRate();
  }

  Future<void> _loadSpeechRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble('speechRate') ?? 0.5;
    _flutterTts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRate', rate);
    _flutterTts.setSpeechRate(rate);
    notifyListeners(); // Notifica a toda la app del cambio
  }
}
