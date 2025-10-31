
class Request {
  final String requestId;
  final int active;
  final String date;
  final int isCancelled;
  final String pickAddress;
  final String requestNumber;
  final String serviceLocationId;
  final int updatedAt;
  final int userId;
  final String? movilAceptado;
  final String? cancelledByUser;
  final double? lat;
  final double? lng;
  final int? messageByUser;
  final String? apiKeyTrazadoRuta;

  Request({
    required this.requestId,
    required this.active,
    required this.date,
    required this.isCancelled,
    required this.pickAddress,
    required this.requestNumber,
    required this.serviceLocationId,
    required this.updatedAt,
    required this.userId,
    this.movilAceptado,
    this.cancelledByUser,
    this.lat,
    this.lng,
    this.messageByUser,
    this.apiKeyTrazadoRuta,
  });

  // Compara todos los atributos excepto lat y lng
  bool isEqualExcludingLatLng(Request other) {
    return requestId == other.requestId &&
        active == other.active &&
        date == other.date &&
        isCancelled == other.isCancelled &&
        pickAddress == other.pickAddress &&
        requestNumber == other.requestNumber &&
        serviceLocationId == other.serviceLocationId &&
        updatedAt == other.updatedAt &&
        userId == other.userId && movilAceptado == other.movilAceptado && cancelledByUser == other.cancelledByUser;
        //  && messageByUser == other.messageByUser;
  }

  factory Request.fromMap(Map<dynamic, dynamic> map) {
    return Request(
      requestId: map['request_id'],
      active: map['active'] ?? 0,
      date: map['date'] ?? '',
      isCancelled: (map['is_cancelled'] == null)
          ? 0
          : (map['is_cancelled'] is bool && map['is_cancelled'])
              ? 1
              : 0,
      pickAddress: map['pick_address'] ?? '',
      requestNumber: map['request_number'] ?? '',
      serviceLocationId: map['service_location_id'] ?? '',
      updatedAt: map['updated_at'] ?? 0,
      userId: map['user_id'] ?? 0,
      movilAceptado: map['movil_aceptado'] ?? '',
      cancelledByUser: map['cancelled_by_user']?.toString() ?? '',
      lat: map['lat'] != null ? map['lat'] as double? : null,
      lng: map['lng'] != null ? map['lng'] as double? : null,
      messageByUser: map['nro_mensajes_cliente'] ?? 0,
      apiKeyTrazadoRuta: map['api_key_trazado_ruta'],
    );
  }
}