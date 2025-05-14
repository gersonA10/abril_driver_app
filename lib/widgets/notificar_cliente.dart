import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificarCliente extends StatelessWidget {
  const NotificarCliente({
    super.key,
    required this.acceptDriverBottomSheetOffset,
    required this.media,
    required this.onTap,
  });

  final ValueNotifier<double> acceptDriverBottomSheetOffset;
  final Size media;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: acceptDriverBottomSheetOffset,
        builder: (context, offset, child) {
          double bottomPadding =
              offset == 0.28 ? 925 * (offset) : 1018 * (offset);
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: bottomPadding,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                  )
                ],
                color: page,
                borderRadius: BorderRadius.circular(media.width * 0.045),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: SizedBox(
                    height: media.width * 0.1,
                    width: media.width * 0.14,
                    child: Icon(
                      Icons.notifications_active,
                      color: newRedColor,
                      size: media.width * 0.07,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class AlertaNotificarLlegada extends StatelessWidget {
  const AlertaNotificarLlegada({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return AlertDialog.adaptive(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: 200,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Notificar llegada',
                    style: GoogleFonts.montserrat(
                        color: newRedColor, fontWeight: FontWeight.bold,
                        fontSize: 17
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: newRedColor,
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                '¿Realmente desea avisar al pasajero que ya se encuentra en el lugar de recogida?',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: themeProvider.isDarkTheme ? Colors.white : textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.025,
            ),
            SizedBox(
      height: size.height * 0.045,
      width: size.width * 0.3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: newRedColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () async {
         notifyBocina();
          ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'EL cliente ha sido notificado',
                      style: const TextStyle(fontSize: 16),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
          );
           Navigator.pop(context);
        },
        child: Text(
          'Enviar',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    ),
          ],
        ),
      ),
    );
  }
}


class Alertas extends StatelessWidget {
  const Alertas({
    super.key, required this.titulo, required this.contenido, this.botonOnTapAceptar, this.botonOnTapSalir, required this.textoBoton,
  });

  final String titulo;
  final String contenido;
  final Function()? botonOnTapAceptar;
  final Function()? botonOnTapSalir;
  final String textoBoton;
  
  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Container(
       color: Colors.black.withOpacity(0.5),
      width: size.width * 1,
      height: size.height * 1,
      child: AlertDialog.adaptive(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          height: 180,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                       titulo,
                      style: GoogleFonts.montserrat(
                          color: newRedColor, fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: botonOnTapSalir,
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: newRedColor,
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  contenido,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: themeProvider.isDarkTheme ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              SizedBox(
        height: size.height * 0.045,
        width: size.width * 0.3,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: newRedColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: botonOnTapAceptar,
          child: Text(
            textoBoton,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
            ],
          ),
        ),
      ),
    );
  }
}
