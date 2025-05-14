import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/widgets/sheetCard/alert_deudas.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonVerDeudas extends StatelessWidget {
  const BotonVerDeudas({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.05,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.22, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: newRedColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return DeudasAlert(size: size);
                });
          },
          child: Text(
            'Ver Deudas',
            style: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
