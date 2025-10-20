// lib/widgets/show_rides.dart
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/functions/rides_services/fetch_data_client_ride.dart';
import 'package:abril_driver_app/models/request_meta.dart';
import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
import 'package:abril_driver_app/providers/handle_drop.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/providers/speech_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/utils/location_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowRides extends StatefulWidget {
  const ShowRides({
    Key? key,
    required this.media,
    required this.listRequests,
    this.onTap,
    required this.rejectedRides,
    this.onDoubleTap,
  }) : super(key: key);

  final List<RequestMeta> listRequests;
  final Size media;
  final VoidCallback? onTap;
  final Function(int index)? onDoubleTap;
  final List<String> rejectedRides;

  @override
  _ShowRidesState createState() => _ShowRidesState();
}

class _ShowRidesState extends State<ShowRides> {
  late ThemeProvider _themeProvider;
  int driverId = userDetails['id'];

  List<double> _cardOffsets = [];
  List<Color> _cardColors = [];
  List<String> _placeDestinations = [];

  @override
  void initState() {
    super.initState();
    _initializeLists();
    _fetchPlaceNames();
  }

  void _initializeLists() {
    _cardOffsets = List.filled(widget.listRequests.length, 0.0);
    _cardColors = List.generate(
      widget.listRequests.length,
      (_) => Colors.white,
    );
    _placeDestinations = List.filled(widget.listRequests.length, 'Cargando...');
  }

  Future<void> _fetchPlaceNames() async {
    for (var i = 0; i < widget.listRequests.length; i++) {
      try {
        final req = widget.listRequests[i];
        if (req.destinoLat != 0.0 && req.destinoLong != 0.0) {
          final dest = await getPlaceName(req.destinoLat!, req.destinoLong!) ?? 'Destino no especificado';
          if (mounted) {
            setState(() {
              _placeDestinations[i] = dest;
            });
          }
        } else {
           if (mounted) {
            setState(() {
              _placeDestinations[i] = 'Destino no especificado';
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _placeDestinations[i] = 'Destino no especificado';
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _cardColors = List.generate(
      widget.listRequests.length,
      (_) => _themeProvider.isDarkTheme ? Colors.grey[800]! : Colors.white,
    );
  }

  @override
  void didUpdateWidget(ShowRides oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listRequests.length != oldWidget.listRequests.length) {
      _initializeLists();
      _fetchPlaceNames();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropProvider = Provider.of<DropProvider>(context, listen: false);
    return Stack(
      children: [
        Container(
          width: widget.media.width,
          height: widget.media.height,
          color: Colors.black.withOpacity(0.5),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: widget.media.height * 0.2),
            itemCount: widget.listRequests.length + 1,
            itemBuilder: (context, idx) {
              if (idx == widget.listRequests.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: widget.media.width * 0.06, top: 10),
                    child: GestureDetector(
                      onTap: widget.onTap,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: newRedColor),
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onDoubleTap: () => widget.onDoubleTap?.call(idx),
                  onHorizontalDragUpdate: (d) => _onDragUpdate(idx, d.delta.dx),
                  onHorizontalDragEnd: (d) => _onDragEnd(idx, d, dropProvider),
                  child: Transform.translate(
                    offset: Offset(_cardOffsets[idx], 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: buildRideCard(
                        context,
                        widget.listRequests[idx],
                        _placeDestinations.isNotEmpty && idx < _placeDestinations.length ? _placeDestinations[idx] : 'Cargando...',
                        '${widget.listRequests[idx].metaDrivers[driverId]?.tiempoMin ?? ''} min',
                        '${widget.listRequests[idx].metaDrivers[driverId]?.distanciaKm ?? ''} km',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onDragUpdate(int idx, double dx) {
    setState(() {
      _cardOffsets[idx] += dx;
      _cardColors[idx] = _cardOffsets[idx] < 0
          ? Colors.green.withOpacity(0.7)
          : (_cardOffsets[idx] > 0 ? Colors.red.withOpacity(0.7) : _cardColors[idx]);
    });
  }

  void _onDragEnd(int idx, DragEndDetails details, DropProvider dropProvider) async {
    final prefs = await SharedPreferences.getInstance();
    if (_cardOffsets[idx] < -150) {
      final req = widget.listRequests[idx];
      await handleRequestAccept(req.requestId, req.recogidaLat!, req.recogidaLong!);
    } else if (_cardOffsets[idx] > 150) {
      widget.rejectedRides.add(widget.listRequests[idx].requestId);
      widget.listRequests.removeAt(idx);
    }
    setState(() {
      _cardOffsets[idx] = 0;
      _cardColors[idx] = _themeProvider.isDarkTheme ? Colors.grey[800]! : Colors.white;
    });
  }

  Future<void> handleRequestAccept(String requestId, double lat, double lng) async {
    try {
      final points = await getRouteFromGraphHopper(
        currentPositionNew!.latitude,
        currentPositionNew!.longitude,
        lat,
        lng,
      );
      await guardarPuntosRuta(points);
      final res = await requestAccept(requestId);
      if (res == 'success') {
        final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
        speechProvider.flutterTts.speak('Aceptaste el viaje, recoge a tu pasajero');
      }
    } catch (e) {
      debugPrint('Error al aceptar: $e');
    }
  }

  Future<void> guardarPuntosRuta(List<LatLng> puntos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonPoints = puntos.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList();
    await prefs.setString('puntosRuta', jsonEncode(jsonPoints));
  }

  Widget buildRideCard(BuildContext context, RequestMeta data, String destination,
      String duration, String distance) {
    final isDark = _themeProvider.isDarkTheme;
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.nomUsuario ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  '$duration | $distance',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.textoZona,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (data.destinoLong != 0.0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.asset('assets/gifs/gif-destino.gif', width: 26),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (data.equipaje) _flagChip('equipaje_1.png', 'Equipaje'),
                if (data.licoreria) _flagChip('licoreria.png', 'Licorería'),
                if (data.mascotas) _flagChip('mascotas.png', 'Mascotas'),
                if (data.parrilla) _flagChip('parrilla_1.png', 'Parrilla'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _flagChip(String asset, String label) => Chip(
        backgroundColor: Colors.grey[200],
        avatar: Image.asset('assets/images/$asset', width: 20, height: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}