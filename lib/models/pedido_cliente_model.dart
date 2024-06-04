import 'package:flutter/material.dart';

class ProductoPedidoCliente {
  final int productoID;
  final String productoNombre;
  final int cantidadProducto;
  final String foto;
  final int? promocionID;
  final String? promocionNombre;
  final int? cantidadPorPromo;
  int? cantidadPromos;
  ProductoPedidoCliente({
    required this.productoID,
    required this.productoNombre,
    required this.cantidadProducto,
    required this.foto,
    required this.promocionID,
    required this.promocionNombre,
    required this.cantidadPorPromo,
  });
}

class PedidoCliente {
  final int id;
  final String estado;
  final double subtotal;
  final double descuento;
  final double total;
  final String? tipoPago;
  final String tipoEnvio;
  final String fecha;
  final String direccion;
  final String distrito;
  String iconoRecibido;
  String iconoProceso;
  String iconoEntregado;
  Color colorRecibido;
  Color colorProceso;
  Color colorEntregado;
  String mensaje;
  double altoIcono;
  double anchoIcono;
  PedidoCliente({
    required this.id,
    required this.estado,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.tipoPago,
    required this.tipoEnvio,
    required this.fecha,
    required this.direccion,
    required this.distrito,
    this.iconoRecibido = '',
    this.iconoProceso = '',
    this.iconoEntregado = '',
    this.colorEntregado = Colors.transparent,
    this.colorProceso = Colors.transparent,
    this.colorRecibido = Colors.transparent,
    this.mensaje = '',
    this.altoIcono = 0.0,
    this.anchoIcono = 0.0,
  });
}
