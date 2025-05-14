import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonMostrarViajesDisponibles extends StatelessWidget {
  const BotonMostrarViajesDisponibles({
    super.key,
    required this.onTap, required this.numViajesDis,
  });

  final Function()? onTap;
  final String numViajesDis;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            color: (userDetails['active'] == false)
              ? const Color(0xff707070).withOpacity(0.6)
              : const Color.fromARGB(255, 184, 1, 1),
          ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: size.height * 0.005),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(size.width * 0.02),
          ),
          width: size.width * 0.35,
          height: size.height * 0.05,
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
                size: size.width * 0.08,
              ),
              Flexible(
                child: Stack(
                  children: [
                    Text(
                      'Viajes Disponibles',
                      maxLines: 2,
                      style: GoogleFonts.aBeeZee(
                        height: size.height * 0.001,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 7,
                      child: Text(
                        numViajesDis,
                        style: GoogleFonts.aBeeZee(
                          height: size.height * 0.001,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
