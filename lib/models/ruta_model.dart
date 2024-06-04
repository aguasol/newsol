class RutaModel {
  final int id;
  final int conductorID;
  final int vehiculoID;
  final String fechaCreacion;
  final String nombreVehiculo;
  final String placaVehiculo;

  RutaModel({
    required this.id,
    required this.conductorID,
    required this.vehiculoID,
    required this.fechaCreacion,
    required this.nombreVehiculo,
    required this.placaVehiculo,
  });
}
