import 'package:appsol_final/models/ubicacion_model.dart';

class UbicacionListaModel {
  List<UbicacionModel> listaUbisObjeto;
  List<String> listaUbisString;

  UbicacionListaModel({
    List<UbicacionModel>? listaUbisObjeto,
    List<String>? listaUbisString,
  })  : listaUbisObjeto = listaUbisObjeto ?? [],
        listaUbisString = listaUbisString ?? [];
}
