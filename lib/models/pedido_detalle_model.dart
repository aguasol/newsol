class DetallePedido {
  final int pedidoID;
  final int productoID;
  final String productoNombre;
  final int cantidadProd;
  final int? promocionID;
  final String? promocionNombre;

  const DetallePedido({
    required this.pedidoID,
    required this.productoID,
    required this.productoNombre,
    required this.cantidadProd,
    required this.promocionID,
    required this.promocionNombre,
  });
}
