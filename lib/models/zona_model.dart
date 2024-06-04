import 'dart:math';

class Zona {
  final int id;
  final String? nombre;
  final String poligono;
  List<Point> puntos;
  String? departamento;
  String? provincia;

  Zona({
    required this.id,
    required this.nombre,
    required this.poligono,
    this.departamento = '',
    this.provincia = '',
    List<Point>? puntos,
  }) : puntos = puntos ?? [];
}
