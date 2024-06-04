import 'package:flutter/material.dart';
import 'package:appsol_final/models/rutaCompleta_model.dart';

class RutaProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  RutaCompletaModel? _ruta;

  // OBTIENES EL USUARIO
  RutaCompletaModel? get ruta => _ruta;

  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  void updateRuta(RutaCompletaModel newRuta) {
    _ruta = newRuta;
    notifyListeners();
  }
}
