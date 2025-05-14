import 'dart:async';

import 'package:flutter/material.dart';

class TemporizadorProvider with ChangeNotifier {
  int tiempoRestante = 5 * 60;
  Timer? _timer;

  void iniciarTemporizador() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (tiempoRestante > 0) {
        tiempoRestante--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  void cancelarTemporizador() {
    _timer?.cancel();
  }
}
