import 'package:flutter/material.dart';
import 'package:appsol_final/models/ubicacion_model.dart';

class UbicacionProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  UbicacionModel? _ubicacion;

  // OBTIENES EL USUARIO
  UbicacionModel? get ubicacion => _ubicacion;

  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  void updateUbicacion(UbicacionModel newUbicacion) {
    _ubicacion = newUbicacion;
    notifyListeners();
  }
}
