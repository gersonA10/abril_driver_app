import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';

class InformacionGeneral extends StatefulWidget {
  const InformacionGeneral({
    super.key,
    required this.size,
    required this.themeProvider,
  });

  final Size size;
  final ThemeProvider themeProvider;

  @override
  State<InformacionGeneral> createState() => _InformacionGeneralState();
}

class _InformacionGeneralState extends State<InformacionGeneral> {
  String licencia = '';
  List<String> tipoVehiculo = [];
  String vehiculo = '';
  String color = '';
  String placa = '';
  String tipovehiculo = '';

  @override
  void initState() {
    super.initState();
    licencia = userDetails['licencia'] ?? '';
    color = userDetails['car_color'].toString();
    placa = userDetails['placa'] ?? '';
    vehiculo ="${userDetails['car_make_name']}, ${userDetails['car_model_name']}";
    for (var i = 0; i < userDetails['driverVehicleType']['data'].length; i++) {
      tipoVehiculo
          .add(userDetails['driverVehicleType']['data'][i]['vehicletype_name']);
      tipovehiculo = tipoVehiculo.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height * 0.22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextosInfoGeneral(
            size: widget.size,
            licencia: 'Licencia:',
            tipoVehiculo: Text(
              'Tipo de Vehiculo:',
              style: TextStyle(color: widget.themeProvider.isDarkTheme ? Color.fromRGBO(217, 217, 217, 1) : newRedColor, fontWeight: FontWeight.bold),
            ),
            vehiculo: 'Vehiculo:',
            color: 'Color:',
            placa: 'Placa:',
            textStyle: TextStyle(
                color: widget.themeProvider.isDarkTheme
                    ? Color.fromRGBO(217, 217, 217, 1)
                    : newRedColor,
                fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
            child: VerticalDivider(),
          ),
          TextosInfoGeneral(
            size: widget.size,
            licencia: licencia,
            tipoVehiculo: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tipovehiculo,
                      style: const TextStyle(fontSize: 16),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Text(
                tipovehiculo,
                style: TextStyle(
                    color: widget.themeProvider.isDarkTheme ? page : textColor,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
              ),
              ),
            ),
            vehiculo: vehiculo,
            color: color,
            placa: placa,
            textStyle: TextStyle(
                color: widget.themeProvider.isDarkTheme ? page : textColor,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class TextosInfoGeneral extends StatelessWidget {
  final String licencia;
  final Widget tipoVehiculo;
  final String vehiculo;
  final String color;
  final String placa;
  final TextStyle textStyle;
  const TextosInfoGeneral({
    super.key,
    required this.size,
    required this.licencia,
    required this.tipoVehiculo,
    required this.vehiculo,
    required this.color,
    required this.placa,
    required this.textStyle,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            licencia,
            style: textStyle,
          ),
          const Divider(),
          tipoVehiculo,
          // Text(
          //   tipoVehiculo,
          //   style: textStyle,
          // ),
          const Divider(),
          Text(
            vehiculo,
            style: textStyle,
          ),
          const Divider(),
          Text(
            color,
            style: textStyle,
          ),
          const Divider(),
          Text(
            placa,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
