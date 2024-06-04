class ProductoPromocion {
  final int promocionId;
  final int productoId;
  final int cantidadProd;
  final int? cantidadPromo;

  ProductoPromocion({
    required this.promocionId,
    required this.productoId,
    required this.cantidadProd,
    required this.cantidadPromo,
  });
}
