import 'package:shared_preferences/shared_preferences.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:intl/intl.dart';

class UserModel {
  /*
  final int id;
  final String nombre;
  final String apellidos;*/
  int? id;
  String? nombre;
  String? apellidos;
  String? sexo;
  double? saldoBeneficio;
  String? codigocliente;
  String? fechaCreacionCuenta;
  String? suscripcion;
  String? frecuencia;
  bool? quiereRetirar;
  bool esNuevo;
  String? token;
  int? rolid;
  String? recargas;

  // Agrega más atributos según sea necesario

  UserModel(
      {/*required this.id,
      required this.nombre,
      required this.apellidos,*/
      this.id,
      this.nombre,
      this.apellidos,
      this.sexo,
      this.saldoBeneficio,
      this.codigocliente,
      this.fechaCreacionCuenta,
      this.suscripcion,
      this.frecuencia,
      this.quiereRetirar,
      this.esNuevo = false,
      this.token,
      this.rolid,
      this.recargas
      // Agrega más parámetros según sea necesario
      });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Obtén la fecha y hora actuales
    final time = DateTime.now();

    // Define el formato deseado
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    // Formatea la fecha y hora actuales al formato deseado
    String formattedDate = dateFormat.format(time);
    /*print("json------------------------------");
    print(json);
    print("usuario json--------------------");*/
    var usuario = json['usuario'];
    //print(usuario);
    /*
    if (usuario == null) {
      // Manejar el caso donde 'usuario' es null
      return UserModel(
        id: 0,
        nombre: 'aguasol',
        apellidos: 'aguasol',
        saldoBeneficio: 0.0,
        codigocliente: 'aguasol',
        fechaCreacionCuenta: formattedDate,
        suscripcion: 'aguasol',
        esNuevo: false,
      );
    }*/
    return UserModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
        apellidos: json['apellidos'] ?? '',
        sexo: json['sexo'],
        saldoBeneficio: (json['saldo_beneficios'] != null)
            ? json['saldo_beneficios'].toDouble()
            : 0.0,
        codigocliente: json['codigocliente'],
        fechaCreacionCuenta: json['fechaCreacionCuenta'],
        suscripcion: json['suscripcion'],
        rolid: json['rolid'] ?? 0,
        recargas: json['recargas'] ?? ''
        // Agrega más inicializaciones según sea necesario
        );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'saldo_beneficios': saldoBeneficio,
      'codigocliente': codigocliente,
      'fechaCreacionCuenta': fechaCreacionCuenta,
      'suscripcion': suscripcion,
      'rolid': rolid,
      'recargas': recargas
    };
  }
}
