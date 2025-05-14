import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverHeaderInformation extends StatefulWidget {
  final Size size;
  final ThemeProvider themeProvider;
  const DriverHeaderInformation({
    super.key,
    required this.size,
    required this.themeProvider,
  });

  @override
  State<DriverHeaderInformation> createState() =>
      _DriverHeaderInformationState();
}

class _DriverHeaderInformationState extends State<DriverHeaderInformation> {
  String name = '';
  String modelCar = '';
  String? placa;
  String? nroMovil;

  @override
  void initState() {
    super.initState();
    name = userDetails['name'].toString();
    modelCar = userDetails['car_model_name'].toString();
    placa = userDetails['placa'].toString();
    nroMovil = userDetails['car_number'] ?? 'Nombre del conductor';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_car,
          size: widget.size.width * 0.16,
          color: Colors.white,
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     // Container(
        //     //   height: 80,
        //     //   width: 80,
        //     //   decoration: BoxDecoration(
        //     //     image: userDetails['profile_picture'] == null
        //     //         ? const DecorationImage(
        //     //             image: AssetImage('assets/images/disablecar.png'),
        //     //             fit: BoxFit.cover,
        //     //           )
        //     //         : DecorationImage(
        //     //             image: NetworkImage(
        //     //               userDetails['profile_picture'],
        //     //             ),
        //     //             fit: BoxFit.cover,
        //     //           ),
        //     //     border: Border.all(color: newRedColor, width: 2.5),
        //     //     borderRadius: BorderRadius.circular(8),
        //     //   ),
        //     // ),
        //     // const SizedBox(height: 5,),
        //     Icon(
        //       Icons.directions_car,
        //       size: widget.size.width * 0.15,
        //     ),
        //   ],
        // ),
        SizedBox(
          width: widget.size.width * 0.07,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flexible(
            //   child: Text(
            //     name,
            //     overflow: TextOverflow.ellipsis,
            //     style: GoogleFonts.montserrat(
            //       fontSize: widget.size.width * 0.04,
            //       color: widget.themeProvider.isDarkTheme
            //           ? const Color.fromRGBO(217, 217, 217, 1)
            //           : newRedColor,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Text(
              '$nroMovil',
              style: GoogleFonts.montserrat(
                  fontSize: widget.size.width * 0.14,
                  letterSpacing: 1.0,
                  color: widget.themeProvider.isDarkTheme ? page : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            // Text(
            //   'Placa: ${placa ?? ''}',
            //   style: GoogleFonts.montserrat(
            //     fontSize: widget.size.width * 0.035,
            //     letterSpacing: 1.0,
            //     color: widget.themeProvider.isDarkTheme
            //         ? const Color.fromRGBO(217, 217, 217, 1)
            //         : textColor,
            //     // fontWeight: FontWeight/
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
