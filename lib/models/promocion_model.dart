import 'package:appsol_final/models/producto_model.dart';

class Promo {
  final int id;
  String nombre;
  final double precio;
  final String descripcion;
  final String fechaLimite;
  final String foto;
  int cantidad;
  int cantidadActual;
  List<Producto> listaProductos;

  Promo({
    required this.id,
    this.nombre = '',
    required this.precio,
    required this.descripcion,
    required this.fechaLimite,
    required this.foto,
    this.cantidad = 0,
    this.cantidadActual = 0,
    List<Producto>? listaProductos,
  }) : listaProductos = listaProductos ?? [];
}
