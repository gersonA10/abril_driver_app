class Deuda {
  final String fechaVencimiento;
  final String concepto;
  final double montoOriginal;
  final double montoMora;
  final double montoTotal;

  Deuda({
    required this.fechaVencimiento,
    required this.concepto,
    required this.montoOriginal,
    required this.montoMora,
    required this.montoTotal,
  });

  factory Deuda.fromJson(Map<String, dynamic> json) {
    return Deuda(
      fechaVencimiento: json['fecha_vencimiento'],
      concepto: json['concepto'],
      montoOriginal: json['monto_original'].toDouble(),
      montoMora: json['monto_mora'].toDouble(),
      montoTotal: json['monto_total'].toDouble(),
    );
  }
}

class DeudaResponse {
  final double deudaTotal;
  final List<Deuda> deudas;

  DeudaResponse({
    required this.deudaTotal,
    required this.deudas,
  });

  factory DeudaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['deudas_coleccion'] as List;
    List<Deuda> deudasList = list.map((i) => Deuda.fromJson(i)).toList();

    return DeudaResponse(
      deudaTotal: json['deuda_total'].toDouble(),
      deudas: deudasList,
    );
  }
}