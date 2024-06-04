import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_model.dart';

class PedidoProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  PedidoModel? _pedido;

  // OBTIENES EL USUARIO
  PedidoModel? get pedido => _pedido;

  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  void updatePedido(PedidoModel newPedido) {
    _pedido = newPedido;
    notifyListeners();
  }
}
