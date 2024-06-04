import 'package:flutter/material.dart';

class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String foto;
  int? promoID;
  int cantidad;
  int cantidadActual;
  int cantidadRequeridaParaRuta;
  int cantidadFaltante;
  String tesobraTefalta;
  String signo;
  Color colorFaltaoSobra;
  TextEditingController cantidadStock;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.foto,
    this.promoID,
    this.cantidad = 0,
    this.cantidadActual = 0,
    this.cantidadFaltante = 0,
    //OARA EL CONDUCTOR
    //cantidad de producto que es necesario pra llevar en el vehiculo
    this.cantidadRequeridaParaRuta = 0,
    this.tesobraTefalta = 'Stock faltante:',
    this.signo = '',
    this.colorFaltaoSobra = const Color.fromRGBO(255, 0, 93, 1.000),
    TextEditingController? cantidadStock,
  }) : cantidadStock = cantidadStock ?? TextEditingController();
}
