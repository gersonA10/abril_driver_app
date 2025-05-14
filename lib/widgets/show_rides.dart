import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:abril_driver_app/providers/speech_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/functions/rides_services/fetch_data_client_ride.dart';
import 'package:abril_driver_app/models/request_meta.dart';
import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
import 'package:abril_driver_app/providers/handle_drop.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/utils/location_manager.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowRides extends StatefulWidget {
  ShowRides({
    super.key,
    required this.media,
    required this.listRequests,
    this.onTap,
    required this.rejectedRides,
    required this.onDoubleTap,
  });

  final List<RequestMeta> listRequests;
  final Size media;
  final Function()? onTap;
  final Function(int index)? onDoubleTap;
  final List<String> rejectedRides;

  @override
  _ShowRidesState createState() => _ShowRidesState();
}

class _ShowRidesState extends State<ShowRides> {
  double _speechRate = 0.5; // Velocidad por defecto
  ThemeProvider themeProvider = ThemeProvider();

  RequestService requestService = RequestService();
  final FlutterTts flutterTts = FlutterTts();
  final Queue _textCola = Queue<String>();
  bool isSpeaking = false;
  // String requestId = "";
  int driverId = userDetails['id'];

  List<double> _cardOffsets = [];
  List<Color> _cardColors = [];
  List<String> _placeNames = [];
  List<String> _placeDestination = [];
  late SpeechProvider _speechProvider;


  @override
  void initState() {
    super.initState();
    _loadSpeechRate();
    _initializeTts();
    _cardOffsets = List.generate(widget.listRequests.length, (index) => 0.0);
    _cardColors = List.generate(widget.listRequests.length,
        (index) => themeProvider.isDarkTheme ? Colors.grey : Colors.white);
    _placeNames =
        List.generate(widget.listRequests.length, (index) => 'Cargando...');
    _placeDestination =
        List.generate(widget.listRequests.length, (index) => 'Cargando...');
    _getPlaceNames();
    flutterTts.setLanguage("es-ES");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
      _readNextText();
    });
  }

  Future<void> _loadSpeechRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('speechRate') ?? 0.5;
    });
  }

  void _initializeTts() {
     _speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    flutterTts.setLanguage("es-ES");
    flutterTts.setPitch(1.0);
    // flutterTts.setSpeechRate(_speechRate); // Aplicar la velocidad inicial
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
      _readNextText();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the themeProvider from the current context
    themeProvider = Provider.of<ThemeProvider>(context);

    // Update the _cardColors based on the current theme
    _cardColors = List.generate(widget.listRequests.length,
        (index) => themeProvider.isDarkTheme ? Colors.grey : Colors.white);

    setState(() {}); // Trigger UI update with new colors
  }

  @override
  void didUpdateWidget(covariant ShowRides oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.listRequests.length != oldWidget.listRequests.length) {
      _cardOffsets = List.generate(widget.listRequests.length, (index) => 0.0);
      _cardColors = List.generate(widget.listRequests.length,
          (index) => themeProvider.isDarkTheme ? Colors.grey : Colors.white);
      _placeNames = List.generate(widget.listRequests.length, (index) => '');
      _placeDestination =
          List.generate(widget.listRequests.length, (index) => '');

      _getPlaceNames();
    }
  }

  Future<void> _getPlaceNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readRequestIds = prefs.getStringList('readRequestIds') ?? [];

    for (int i = 0; i < widget.listRequests.length; i++) {
      final lat = widget.listRequests[i].destinoLat;
      final long = widget.listRequests[i].destinoLong;
      final requestId = widget.listRequests[i].requestId;

      // Verificar si el requestId ya ha sido leído
      if (!readRequestIds.contains(requestId)) {
        try {
          String placeDestination = await getPlaceName(lat!, long!) ?? '';
          String placeName = widget.listRequests[i].textoZona;
          setState(() {
            _placeDestination[i] = placeDestination;
            _placeNames[i] = placeName;
          });

          // Agregar el texto a la cola
          _textCola.add(placeName);
          _readNextText();

          readRequestIds.add(requestId);
          await prefs.setStringList('readRequestIds', readRequestIds);
        } catch (e) {
          // setState(() {
          //   _placeNames[i] = 'No disponible';
          // });

          // _textCola.add('No disponible');
          _readNextText();
        }
      } else {
        print('El requestId $requestId ya ha sido leído.');
      }
    }
  }

  Future<void> _readNextText() async {
    if (_textCola.isNotEmpty && !isSpeaking) {
      final text = _textCola.removeFirst();
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropProvider = Provider.of<DropProvider>(context);
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.black.withOpacity(0.5),
      width: widget.media.width * 1,
      height: widget.media.height * 1,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.2),
          itemCount: widget.listRequests.length + 1,
          itemBuilder: (BuildContext context, int index) => (index ==
                  widget.listRequests.length)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.06, top: 10),
                    child: GestureDetector(
                      onTap: widget.onTap,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_back,
                          color: newRedColor,
                        ),
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onDoubleTap: () {
                    if (widget.onDoubleTap != null) {
                      widget.onDoubleTap!(index);
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _cardOffsets[index] += details.delta.dx;

                      if (_cardOffsets[index] > 0) {
                        _cardColors[index] = Colors.red.withOpacity(0.7);
                      } else if (_cardOffsets[index] < 0) {
                        _cardColors[index] = Colors.green.withOpacity(0.7);
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (_cardOffsets[index] < -150) {
                      //*Aca solamente habria que colocar el metodo que ya exite al aceptar carrera
                      setState(() {
                        requestId = widget.listRequests[index].requestId;
                        latitudeDestino = widget.listRequests[index].destinoLat;
                        longitudeDestino = widget.listRequests[index].destinoLong;
                        latRecoger = widget.listRequests[index].recogidaLat;
                        lonRecoger = widget.listRequests[index].recogidaLong;
                        recogida = _placeNames[index];
                        destino = _placeDestination[index];
                        endPoint = LatLng(latRecoger!, lonRecoger!);
                      });

                      if (latRecoger != null) {
                        await prefs.setDouble('latRecoger', latRecoger!);
                        latRecoger = prefs.getDouble('latRecoger');
                      }
                      if (lonRecoger != null) {
                        await prefs.setDouble('lonRecoger', lonRecoger!);
                        lonRecoger = prefs.getDouble('lonRecoger');
                      }
                      if (recogida != null || recogida != '') {
                        await prefs.setString('recogida', recogida!);
                      }
                      if (destino != null || destino != '') {
                        await prefs.setString('destino', destino!);
                      }

                      if (requestId != null) {
                        await prefs.setString('requestId', requestId!);
                        final idRequest = prefs.getString('requestId');
                        handleRequestAccept(
                            idRequest!, latRecoger!, lonRecoger!);
                      }

                      // Guardar `endPoint` en `SharedPreferences`
                      if (endPoint != null) {
                        await prefs.setDouble(
                            'endPointLat', endPoint!.latitude);
                        await prefs.setDouble(
                            'endPointLng', endPoint!.longitude);
                      }

                      if (latitudeDestino != 0.0) {
                        await prefs.setDouble('latitudeDestino', latitudeDestino!);
                        await prefs.setDouble('longitudeDestino', longitudeDestino!);
                        // _handleDrop(requestId!, latitudeDestino!, longitudeDestino!);
                        dropProvider.handleDrop(requestId!, latitudeDestino!, longitudeDestino!);
                      }
                    } else if (_cardOffsets[index] > 150) {
                      widget.rejectedRides
                          .add(widget.listRequests[index].requestId);
                      widget.listRequests.removeAt(index);
                      //*Aca si el driver eliminca la carrera solo lo eliminara de su vista de el, es decir la carrera seguira en firebase
                    }
                    setState(() {
                      _cardOffsets[index] = 0;
                      _cardColors[index] = themeProvider.isDarkTheme
                          ? Colors.grey
                          : Colors.white;
                    });
                  },
                  child: Transform.translate(
                    offset: Offset(_cardOffsets[index], 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRideCard(
                            size,
                            _cardColors[index],
                            widget.listRequests[index],
                            _placeDestination[index],
                            widget.listRequests[index].metaDrivers[driverId]
                                    ?.distanciaKm
                                    .toString() ??
                                '',
                            widget.listRequests[index].metaDrivers[driverId]
                                    ?.tiempoMin
                                    .toString() ??
                                ''),
                      ],
                    ),
                  ),
                )),
    );
  }

 Future<void> handleRequestAccept(String requestId, double latitudeRecogida, double longitudeRecogida) async {
    setState(() {
      estaCargando = true; // Mostrar loader
    });

    try {
      // Obtén los puntos de la ruta
      List<LatLng> points = await getRouteFromGraphHopper(
        currentPositionNew!.latitude,
        currentPositionNew!.longitude,
        latitudeRecogida,
        longitudeRecogida,
      );

      // Guarda los puntos y actualiza el estado
      setState(() {
        routePoints = points;
      });

      await guardarPuntosRuta(routePoints);

      // Acepta la solicitud
      final res = await requestAccept(requestId);
      if (res == 'success') {
      flutterTts.speak('Aceptaste el viaje, recoge a tu pasajero');
        
      }
    } catch (error) {
      // Manejo de errores
      print('Error al aceptar la carrera: $error');
    } finally {
      // Ocultar loader
      // setState(() {
        estaCargando = false;
      // });
    }
  }
  Future<void> guardarPuntosRuta(List<LatLng> puntos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convertir los puntos LatLng a una lista de mapas
    List<Map<String, double>> puntosMap = puntos
        .map((punto) =>
            {'latitude': punto.latitude, 'longitude': punto.longitude})
        .toList();

    // Convertir la lista de mapas a una cadena JSON
    String puntosJson = jsonEncode(puntosMap);

    // Guardar la cadena JSON en SharedPreferences
    await prefs.setString('puntosRuta', puntosJson);
  }


  Widget buildRideCard(Size size, Color cardColor, RequestMeta requestMeta,
      String placeName, String distancia, String tiempo) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      height: requestMeta.equipaje == true ||
              requestMeta.licoreria == true ||
              requestMeta.mascotas == true ||
              requestMeta.parrilla == true
          ? 125
          : 95,
      child: Card(
        color: themeProvider.isDarkTheme ? Colors.white : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: size.width * 0.42,
                      child: Text(
                        '${requestMeta.nomUsuario} ',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: themeProvider.isDarkTheme ? Colors.black : Colors.black,
                            fontWeight: FontWeight.w700, letterSpacing: -0.5),
                      )),
                  Text(' $tiempo min | $distancia km | ', style: TextStyle(color: themeProvider.isDarkTheme ? Colors.black : Colors.black),),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.74,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade400,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: size.width * 0.04,
                          width: size.width * 0.04,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.green),
                          child: Container(
                            height: size.width * 0.02,
                            width: size.width * 0.02,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Text(
                            requestMeta.textoZona,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 15, 
                              fontWeight: FontWeight.normal,
                              color:themeProvider.isDarkTheme ? Colors.black : Colors.black
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  requestMeta.destinoLong == 0.0
                      ? Container()
                      : Container(
                          height: size.width * 0.055,
                          width: size.width * 0.055,
                          alignment: Alignment.center,
                          // decoration: const BoxDecoration(
                          //     shape: BoxShape.circle, color: Colors.red,
                          // ),
                          child: Image.asset('assets/gifs/gif-destino.gif')),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Equipaje
                    requestMeta.equipaje == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  200], // Color de fondo similar al ejemplo
                              borderRadius: BorderRadius.circular(
                                  30), // Bordes redondeados
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/equipaje_1.png',
                                  height: 20, // Tamaño de la imagen ajustado
                                  width: 20,
                                ),
                                SizedBox(
                                    width: 8), // Espacio entre icono y texto
                                Text(
                                  'Equipaje',
                                  style: TextStyle(
                                    color: Colors.black, // Color del texto
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),

                    SizedBox(width: 10), // Separación entre elementos

                    // Licorería
                    requestMeta.licoreria == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  200], // Color de fondo similar al ejemplo
                              borderRadius: BorderRadius.circular(
                                  30), // Bordes redondeados
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/licoreria.png',
                                  height: 20, // Tamaño de la imagen ajustado
                                  width: 20,
                                ),
                                SizedBox(
                                    width: 8), // Espacio entre icono y texto
                                Text(
                                  'Licorería',
                                  style: TextStyle(
                                    color: Colors.black, // Color del texto
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),

                    SizedBox(width: 10), // Separación entre elementos

                    // Mascotas
                    requestMeta.mascotas == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  200], // Color de fondo similar al ejemplo
                              borderRadius: BorderRadius.circular(
                                  30), // Bordes redondeados
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/mascotas.png',
                                  height: 20, // Tamaño de la imagen ajustado
                                  width: 20,
                                ),
                                SizedBox(
                                    width: 8), // Espacio entre icono y texto
                                Text(
                                  'Mascotas',
                                  style: TextStyle(
                                    color: Colors.black, // Color del texto
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),

                    SizedBox(width: 10), // Separación entre elementos

                    // Parrilla
                    requestMeta.parrilla == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  200], // Color de fondo similar al ejemplo
                              borderRadius: BorderRadius.circular(
                                  30), // Bordes redondeados
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/parrilla_1.png',
                                  height: 20, // Tamaño de la imagen ajustado
                                  width: 20,
                                ),
                                SizedBox(
                                    width: 8), // Espacio entre icono y texto
                                Text(
                                  'Parrilla',
                                  style: TextStyle(
                                    color: Colors.black, // Color del texto
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),

              // requestMeta.destinoLong == 0.0
              //     ? Container()
              //     : Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 5, vertical: 5),
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10),
              //             border: Border.all(color: Colors.grey)),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             Container(
              //               height: size.width * 0.04,
              //               width: size.width * 0.04,
              //               alignment: Alignment.center,
              //               decoration: const BoxDecoration(
              //                   shape: BoxShape.circle, color: Colors.red),
              //               child: Container(
              //                 height: size.width * 0.02,
              //                 width: size.width * 0.02,
              //                 decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     color: Colors.white.withOpacity(0.8)),
              //               ),
              //             ),
              //             const SizedBox(
              //               width: 5,
              //             ),
              //             Text(
              //               placeName,
              //               style: GoogleFonts.montserrat(
              //                   fontSize: 12, fontWeight: FontWeight.bold),
              //             ),
              //           ],
              //         ),
              //       ),
            ],
          ),
        ),
      ),
    );
  }
}
