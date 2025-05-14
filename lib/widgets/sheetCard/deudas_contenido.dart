import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyDeudas extends StatelessWidget {
  const BodyDeudas({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      // color: Colors.amber,
      width: size.width * 1,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fecha',
            style: GoogleFonts.montserrat(
              color: newRedColor,
              fontSize: 13,
              fontWeight: FontWeight.bold
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: VerticalDivider(),
          ),
          Text(
            'Concepto',
            style: GoogleFonts.montserrat(
              color: newRedColor,
              fontSize: 13,
              fontWeight: FontWeight.bold
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: VerticalDivider(),
          ),
          Text(
            'Monto',
            style: GoogleFonts.montserrat(
              color: newRedColor,
              fontSize: 13,
              fontWeight: FontWeight.bold
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: VerticalDivider(),
          ),
          Text('D.Mora', style: GoogleFonts.montserrat(
              color: newRedColor,
              fontSize: 13,
              fontWeight: FontWeight.bold
            ),)
        ],
      ),
    );
  }
}
