import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/functions/rides_services/fetch_data_client_ride.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropProvider extends ChangeNotifier {
  RequestService requestService = RequestService();
  List<LatLng> routePointsDestino = [];
  bool mostrardDibujadoDestino = false;
  // double? latitudeDestino;
  // double? longitudeDestino;

  void handleDrop(String requestId, double latDestino, double longDestino) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    requestService.getDriverIdStream(requestId).listen((driverId) async {
      if (driverId != userDetails['id'].toString()) {
        print("Este conductor no está asignado a la carrera.");
        return;
      }
      try {
        if (latRecoger != null && latitudeDestino != null) {
          List<LatLng> points = await getRouteFromGraphHopper(
            latRecoger!,
            lonRecoger!,
            latitudeDestino!,
            longitudeDestino!,
          );
          routePointsDestino = points;
          await guardarPuntosRutaDestino(routePointsDestino);

          mostrardDibujadoDestino = true;
          await prefs.setBool(
              'mostrardDibujadoDestino', mostrardDibujadoDestino);
          notifyListeners();
        }
      } catch (e) {
        print('Error al obtener la ruta: $e');
      }
    });
  }

  Future<void> guardarPuntosRutaDestino(List<LatLng> puntos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convertir los puntos LatLng a una lista de mapas
    List<Map<String, double>> puntosMap = puntos
        .map((punto) =>
            {'latitude': punto.latitude, 'longitude': punto.longitude})
        .toList();

    // Convertir la lista de mapas a una cadena JSON
    String puntosJson = jsonEncode(puntosMap);

    // Guardar la cadena JSON en SharedPreferences
    await prefs.setString('puntosRutaDestino', puntosJson);
  }

  Future<void> cargarPuntosRutaDestino() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtener la cadena JSON desde SharedPreferences
    String? puntosJson = prefs.getString('puntosRutaDestino');
    bool? mostrarDestino = prefs.getBool('mostrardDibujadoDestino');

    if (puntosJson != null) {
      // Decodificar la cadena JSON a una lista de mapas
      List<dynamic> listaPuntos = jsonDecode(puntosJson);

      // Convertir la lista de mapas a una lista de objetos LatLng
      List<LatLng> puntos = listaPuntos
          .map((punto) => LatLng(punto['latitude'], punto['longitude']))
          .toList();

      routePointsDestino = puntos;
      mostrardDibujadoDestino = mostrarDestino!;
      notifyListeners();
    }
  }

// /  Future<void> cargarLatLonDestino() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Obtener la cadena JSON desde SharedPreferences
  //   double? lonDestino = prefs.getDouble('longitudeDestino');
  //   double? latDestino = prefs.getDouble('latitudeDestino');

  //   if (lonDestino != null && latDestino != null) {
  //     // Asignar los puntos cargados a `routePoints`
  //     latitudeDestino = latDestino;
  //     longitudeDestino = lonDestino;
  //     notifyListeners();
  //   }
  // }
}
