class Pedido {
  final int id;
  final double montoTotal;
  final String tipo;
  final String fecha;
  String estado;
  String? tipoPago;

  ///REVISAR EN QUÈ FORMATO SE RECIVE LA FECHA
  final String nombre;
  final String apellidos;
  final String telefono;
  //final String ubicacion;
  final double latitud;
  final double longitud;
  final String direccion;
  int? beneficiadoID;
  String comentario;

  Pedido({
    required this.id,
    required this.montoTotal,
    required this.tipo,
    required this.fecha,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    //required this.ubicacion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.estado = 'en proceso',
    this.comentario = '',
    this.tipoPago,
    required beneficiadoID,
  });
}
