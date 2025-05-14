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

  final bool equipaje;
  final bool licoreria;
  final bool mascotas;
  final bool parrilla;

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
    required this.equipaje,
    required this.licoreria,
    required this.mascotas,
    required this.parrilla,

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
      destinoLong: map['destino_long'] ?? 0.0,
      destinoLat: map['destino_lat'] ?? 0.0,
      equipaje: map['equipaje'],
      licoreria: map['licoreria'],
      mascotas: map['mascotas'],
      parrilla: map['parrilla'],
    );
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

