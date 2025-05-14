import 'dart:developer';

abstract class Mylogger {
  static void print(String msg) {
    log('LOGS $msg');
  }

  static void printWithTime(String msg) {
    log('LOGS(${DateTime.now()}) $msg');
  }
}
