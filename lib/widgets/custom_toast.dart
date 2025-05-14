import 'package:flutter/material.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomToast {
  static void show(BuildContext context, String message) {
     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        child: AlertDialog.adaptive(
          backgroundColor: Colors.grey,
          content: Text(message, style: TextStyle(color: themeProvider.isDarkTheme ? Colors.white: Colors.white),),
        ),

      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
