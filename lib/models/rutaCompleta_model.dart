class RutaCompletaModel {
  final int rutaIDpref;
  final int totalPendiente;
  final double totalMonto;
  final double totalYape;
  final double totalPlin;
  final double totalEfectivo;
  final int totalEntregado;
  final List<int> idpedidos;
  final int totalTruncado;

  RutaCompletaModel({
    required this.rutaIDpref,
    required this.totalPendiente,
    required this.totalMonto,
    required this.totalYape,
    required this.totalPlin,
    required this.totalEfectivo,
    required this.totalEntregado,
    required this.idpedidos,
    required this.totalTruncado,
  });
}
