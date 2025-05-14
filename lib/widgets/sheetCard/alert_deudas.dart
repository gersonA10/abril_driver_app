import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/models/deuda_model.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/widgets/sheetCard/deudas_contenido.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DeudasAlert extends StatefulWidget {
  const DeudasAlert({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<DeudasAlert> createState() => _DeudasAlertState();
}

class _DeudasAlertState extends State<DeudasAlert> {
  DeudaResponse? deudaResponse;

  int driverID = userDetails['id'];

  @override
  void initState() {
    super.initState();
    _cargarDeudas();
  }

  Future<void> _cargarDeudas() async {
    final res = await obtenerDeudas(driverID);
    setState(() {
      deudaResponse = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return AlertDialog.adaptive(
      // contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.size.height * 0.45,
        // width: widget.size.width * 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deuda Total',
              style: GoogleFonts.montserrat(
                  color: newRedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '${deudaResponse?.deudaTotal ?? 0.00} bs.',
              style: GoogleFonts.montserrat(
                color: themeProvider.isDarkTheme ? Colors.white : textColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            //*Deudas contenido
            const BodyDeudas(),
            const Divider(),
            deudaResponse == null
                ? SizedBox(
                    height: widget.size.height * 0.2,
                    width: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: newRedColor,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Table(
                      children: [
                        for (var deuda in deudaResponse!.deudas)
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  deuda.fechaVencimiento,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          deuda.concepto,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    deuda.concepto,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  deuda.montoOriginal.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  deuda.montoMora.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: widget.size.width * 0.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: newRedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style:
                      GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
