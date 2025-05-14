import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/models/deuda_model.dart';
import 'package:abril_driver_app/styles/styles.dart';

class DeudasScreen extends StatefulWidget {
  const DeudasScreen({Key? key}) : super(key: key);

  @override
  _DeudasScreenState createState() => _DeudasScreenState();
}

class _DeudasScreenState extends State<DeudasScreen> {
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200.0), // Tamaño del AppBar
        child: AppBar(
          flexibleSpace: _buildCurvedAppBarContent(context), // Contenido curvado
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: deudaResponse == null
            ? Center(
                child: CircularProgressIndicator(
                  color: newRedColor,
                ),
              )
            : SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      deudaResponse!.deudas.isEmpty ? 'Sin deudas' : 'Detalle de Deudas',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    // _buildDeudasTable(), // Aquí se muestra la tabla de deudas
                    for (var deuda in deudaResponse!.deudas)
                    DebtCard(fecha: deuda.fechaVencimiento, concepto: deuda.concepto, monto: deuda.montoTotal.toString(), demora: deuda.montoMora.toString())
                  ],
                ),
            ),
      ),
    );
  }

  Widget _buildCurvedAppBarContent(BuildContext context) {
    return ClipPath(
      clipper: CustomAppBarClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Color.fromARGB(255, 183, 44, 34)],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Deudas del Conductor',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Total de Deudas: ${deudaResponse?.deudaTotal ?? 0.00} bs.',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeudasTable() {
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Fecha',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Concepto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Monto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'D.Mora',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          for (var deuda in deudaResponse!.deudas)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    deuda.fechaVencimiento,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(deuda.concepto),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                    child: Text(
                      deuda.concepto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    deuda.montoOriginal.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class DebtCard extends StatelessWidget {
  final String fecha;
  final String concepto;
  final String monto;
  final String demora;

  DebtCard({
    required this.fecha,
    required this.concepto,
    required this.monto,
    required this.demora,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: $fecha',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Concepto: $concepto',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monto: $monto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  'D.Mora: $demora',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}