import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false; // Estado inicial del tema

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;

  final ThemeData darkTheme = ThemeData.dark(); // Tema oscuro
  final ThemeData lightTheme = ThemeData.light(); // Tema claro

  ThemeProvider() {
    _loadTheme(); // Cargar el tema al iniciar
  }

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    _saveTheme(); // Guardar la preferencia
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }
}
