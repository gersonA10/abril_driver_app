import 'package:flutter/material.dart';

class RequestMeta {
  final String requestId;
  final int? active;
  final String? driverId;
  final Map<int, MetaDriver> metaDrivers;  
  final String? nomUsuario;
  final double? recogidaLat;
  final double? recogidaLong;
  final double? destinoLat;
  final double? destinoLong;
  final String textoZona;
  final String textoZonaDescriptivo;
  final String? apiKeyTrazadoRuta;
  final bool equipaje;
  final bool licoreria;
  final bool mascotas;
  final bool parrilla;
  final Color? colorLlamada;
  final Color? colorTexto;

  RequestMeta({
    required this.requestId,
    required this.active,
    required this.driverId,
    required this.metaDrivers,  
    required this.nomUsuario,
    required this.recogidaLat,
    required this.recogidaLong,
    required this.destinoLong,
    required this.destinoLat,
    required this.textoZona,
    required this.textoZonaDescriptivo,
    required this.equipaje,
    required this.licoreria,
    required this.mascotas,
    required this.parrilla,
    this.apiKeyTrazadoRuta,
    this.colorLlamada,
    this.colorTexto
  });

  factory RequestMeta.fromMap(Map<dynamic, dynamic> map) {
    Map<int, MetaDriver> drivers = {};
    if (map['meta-drivers'] != null) {
      map['meta-drivers'].forEach((key, value) {
        drivers[int.parse(key)] = MetaDriver.fromMap(value);
      });
    }

    return RequestMeta(
      requestId: map['request_id'] ?? '',
      active: map['active'] ?? 0,
      driverId: (map['driver_id'] is int)
       ? (map['driver_id'] as int).toString() 
       : (map['driver_id'] ?? '0'),
      metaDrivers: drivers,
      nomUsuario: map['nombre_usuario'] ?? '',
      recogidaLat: map['recogida_lat'] ?? 0.0,
      recogidaLong: map['recogida_long'] ?? 0.0,
      textoZona: map['texto_zona'] ?? '',
      textoZonaDescriptivo: map['texto_zona_descriptivo'],
      destinoLong: map['destino_long'] ?? 0.0,
      destinoLat: map['destino_lat'] ?? 0.0,
      apiKeyTrazadoRuta: map['api_key_trazado_ruta'],
      equipaje: map['equipaje'],
      licoreria: map['licoreria'],
      mascotas: map['mascotas'],
      parrilla: map['parrilla'],
      colorLlamada: _colorFromHex(map['color_llamada'] as String?),
      colorTexto: _colorFromHex(map['color_texto'] as String?),
    );
  }

  static Color? _colorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;

    // 1. Quita el carácter '#'
    final hexCode = hexColor.replaceAll('#', '');

    // 2. Comprueba la longitud
    if (hexCode.length == 6) {
      // Es un color RGB (como tu #FF6B6B)
      // Se le añade 'FF' al inicio para opacidad completa
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    
    if (hexCode.length == 8) {
      // Es un color ARGB (como tu #FFFFFFFF)
      return Color(int.parse(hexCode, radix: 16));
    }
    
    return null; // Formato no reconocido
  }
}

class MetaDriver {
  final double distanciaKm;
  final int tiempoMin;

  MetaDriver({
    required this.distanciaKm,
    required this.tiempoMin,
  });

  factory MetaDriver.fromMap(Map<dynamic, dynamic> map) {
    return MetaDriver(
      distanciaKm: (map['distancia_km'] is int) ? (map['distancia_km'] as int).toDouble() : (map['distancia_km'] ?? 0.0),
      tiempoMin: map['tiempo_min'] ?? 0,
    );
  }
}

