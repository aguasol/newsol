import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  State<PerfilCliente> createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  late UserModel clienteUpdate;
  Color colorTitulos = const Color.fromARGB(255, 3, 34, 60);
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorInhabilitado = const Color.fromARGB(255, 130, 130, 130);
  bool estaHabilitado = false;
  String mensajeBanco = 'Numero de celular, cuenta o CCI';
  List<String> mediosString = ['Yape', 'Plin', 'Transferencia'];
  List<String> bancosString = ['BCP', 'BBVA', 'Caja Arequipa', 'Otros'];
  bool esYape = false;
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _cuenta = TextEditingController();
  String telefono_ = '';
  String cuenta_ = '';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCliente = '/api/cliente/';
  DateTime fechaLimite = DateTime.now();
  TextEditingController numeroDeCuenta = TextEditingController();
  String numrecargas = '';
  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      //print('es string');
      return DateTime.parse(fecha);
    } else {
      //print('no es string');
      return DateTime.now();
    }
  }

  Future<dynamic> updateCliente(saldoBeneficios, suscripcion, frecuencia,
      quiereretirar, clienteID, medioretiro, bancoretiro, numerocuenta) async {
    /*print("cliente----------------------------------------------");
    print(clienteID);
    print("ruta------------------------------------------------");
    print(apiUrl + apiCliente + clienteID.toString());*/
    await http.put(Uri.parse(apiUrl + apiCliente + clienteID.toString()),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "saldo_beneficios": saldoBeneficios,
          "suscripcion": suscripcion,
          "frecuencia": frecuencia,
          "quiereretirar": quiereretirar,
          "medio_retiro": medioretiro,
          "banco_retiro": bancoretiro,
          "numero_cuenta": numerocuenta
        }));
   // print("RUTA ACTUALIZADA A ");
  }

  void actualizarProviderCliente(
      clienteid,
      name,
      lastname,
      saldo,
      codigo,
      fechaCreacion,
      sexo,
      frecuencia,
      suscrip,
      medioretiro,
      bancoretiro,
      numerocuenta) async {
    clienteUpdate = UserModel(
        id: clienteid,
        nombre: name,
        apellidos: lastname,
        saldoBeneficio: saldo,
        codigocliente: codigo,
        fechaCreacionCuenta: fechaCreacion,
        sexo: sexo,
        frecuencia: frecuencia,
        quiereRetirar: true,
        suscripcion: suscrip,
        rolid: 4);
    Provider.of<UserProvider>(context, listen: false).updateUser(clienteUpdate);
    await updateCliente(saldo, suscrip, frecuencia, true, clienteid,
        medioretiro, bancoretiro, numerocuenta);
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    //TYJYUJY
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(anchoActual * 0.04),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: largoActual * 0.033,
              ),
              Row(
                children: [
                  //FOTO DEL CLIENTE
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.035),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 218, 218, 218),
                        borderRadius: BorderRadius.circular(50)),
                    height: largoActual * 0.085,
                    width: anchoActual * 0.18,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      //poner un if por aqui por si es hombre o mujer
                      child: userProvider.user?.sexo == 'Femenino'
                          ? Icon(
                              Icons.face_3_rounded,
                              color: colorTitulos,
                              size: anchoActual * 0.14,
                            )
                          : Icon(
                              Icons.face_6_rounded,
                              color: colorTitulos,
                              size: anchoActual * 0.14,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: anchoActual * 0.05,
                  ),

                  SizedBox(
                    width: anchoActual * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Nombre
                        Text(
                          '${userProvider.user?.nombre} ${userProvider.user?.apellidos}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: largoActual * 0.023,
                              color: colorTitulos),
                        ),
                        //Correo
                        Text(
                          'Codigo: ${userProvider.user?.codigocliente}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: largoActual * 0.02,
                              color: colorTitulos),
                        ),
                        //Numero
                        Text(
                          '${userProvider.user?.suscripcion}',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: largoActual * 0.018,
                              color: colorTitulos),
                        ),
                      ],
                    ),
                  ), /*
                  */
                ],
              ),

              //CARDS DE INFOPERSONAL MEMBRE SOL CUPONES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierColor: Colors.grey.withOpacity(0.41),
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      width: 150,
                                      height: 230,
                                      child: Image.network('$apiUrl/images/sorteo.jpg'),
                                    ),
                                  );
                                });
                          },
                          child: Row(
                            children: [
                              Container(
                                  //color: Colors.amber,
                                  padding:
                                      EdgeInsets.only(left: anchoActual * 0.04),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: "${userProvider.user?.recargas}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: largoActual * 0.06,
                                        color: colorTitulos,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\nrecargas",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.016,
                                          color: colorTitulos,
                                          height: 0.2),
                                    ),
                                    TextSpan(
                                      text: "\no oportunidades",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.016,
                                          color: colorTitulos),
                                    )
                                  ]))),
                              Container(
                                height: largoActual * 0.12,
                                width: anchoActual * 0.31,
                                //color: Colors.grey,
                                child: Lottie.asset(
                                  'lib/imagenes/Animation - 1718738830493.json',
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),

                  //CARD DE INFO PERSONAL
                  Expanded(
                    flex: 1,
                    child: Card(
                        margin: EdgeInsets.only(left: anchoActual * 0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        child: Container(
                          margin: EdgeInsets.all(anchoActual * 0.02),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  //ACA ACCIONES
                                },
                                icon: Icon(
                                  Icons.person_2_outlined,
                                  color: colorLetra,
                                  size: anchoActual * 0.11,
                                ),
                              ),
                              Text(
                                'Info. Personal',
                                style: TextStyle(
                                    color: colorLetra,
                                    fontWeight: FontWeight.w400,
                                    fontSize: largoActual * 0.015),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),

              //BILLETERA SOL
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.045),
                    child: Text(
                      "Billetera Sol",
                      style: TextStyle(
                          color: colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: largoActual * (16 / 760)),
                    ),
                  ),
                  SizedBox(
                    height: largoActual * 0.19,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        surfaceTintColor: Color.fromRGBO(246, 224, 128, 1.000),
                        color: Colors.white,
                        elevation: 8,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: anchoActual * 0.1,
                            right: anchoActual * 0.1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'S/. ${userProvider.user?.saldoBeneficio}0',
                                    style: TextStyle(
                                        color: colorLetra,
                                        fontWeight: FontWeight.w700,
                                        fontSize: largoActual * 0.045),
                                  ),
                                  Text(
                                    'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                    style: TextStyle(
                                        color: colorLetra,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.016),
                                  ),
                                  SizedBox(
                                    height: largoActual * 0.01,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        (168 / 375),
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String _selectedItem =
                                                'Seleccione su metodo';
                                            String _otroItem =
                                                'Ingrese su banco';
                                            return Dialog(
                                              child: StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(
                                                              150, 198, 230, 1),
                                                          Colors.white,
                                                          Colors.white,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Selecciona el metodo que prefieras',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.028,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          Column(
                                                            children: [
                                                              DropdownButtonFormField<
                                                                  String>(
                                                                onChanged: (String?
                                                                    newValue) {
                                                                  setState(() {
                                                                    _selectedItem =
                                                                        newValue!;
                                                                    /*print(
                                                                        'valor: $_selectedItem');*/
                                                                  });
                                                                },
                                                                value:
                                                                    _selectedItem,
                                                                items: <String>[
                                                                  'Seleccione su metodo',
                                                                  'Transferencia',
                                                                  'Yape o plin',
                                                                ].map<
                                                                    DropdownMenuItem<
                                                                        String>>((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    _selectedItem ==
                                                                        'Transferencia',
                                                                child: Column(
                                                                  children: [
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                      onChanged:
                                                                          (String?
                                                                              newValue) {
                                                                        setState(
                                                                            () {
                                                                          _otroItem =
                                                                              newValue!;
                                                                        });
                                                                      },
                                                                      value:
                                                                          _otroItem,
                                                                      items:
                                                                          <String>[
                                                                        'Ingrese su banco',
                                                                        'BBVA',
                                                                        'BCP',
                                                                        'Caja Arequipa',
                                                                        'Otros',
                                                                      ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                    TextFormField(
                                                                      controller:
                                                                          _cuenta,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        hintText:
                                                                            'Ingrese su numero de cuenta',
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Por favor, ingrese su numero de cuenta';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        actualizarProviderCliente(
                                                                            userProvider.user?.id,
                                                                            userProvider.user?.nombre,
                                                                            userProvider.user?.apellidos,
                                                                            userProvider.user?.saldoBeneficio,
                                                                            userProvider.user?.codigocliente,
                                                                            userProvider.user?.fechaCreacionCuenta,
                                                                            userProvider.user?.sexo,
                                                                            userProvider.user?.frecuencia,
                                                                            userProvider.user?.suscripcion,
                                                                            _selectedItem,
                                                                            _otroItem,
                                                                            _cuenta.text);
                                                                        cuenta_ =
                                                                            _cuenta.text;
                                                                        _cuenta.text =
                                                                            '';
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _showThankYouDialog(
                                                                            context);
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        elevation:
                                                                            MaterialStateProperty.all(8),
                                                                        surfaceTintColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Aceptar",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000),
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    _selectedItem ==
                                                                        'Yape o plin',
                                                                child: Column(
                                                                  children: [
                                                                    TextFormField(
                                                                      controller:
                                                                          _telefono,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        hintText:
                                                                            'Ingrese su numero de telefono',
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Por favor, ingrese su numero';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        actualizarProviderCliente(
                                                                            userProvider.user?.id,
                                                                            userProvider.user?.nombre,
                                                                            userProvider.user?.apellidos,
                                                                            userProvider.user?.saldoBeneficio,
                                                                            userProvider.user?.codigocliente,
                                                                            userProvider.user?.fechaCreacionCuenta,
                                                                            userProvider.user?.sexo,
                                                                            userProvider.user?.frecuencia,
                                                                            userProvider.user?.suscripcion,
                                                                            _selectedItem,
                                                                            null,
                                                                            _telefono.text);
                                                                        telefono_ =
                                                                            _telefono.text;
                                                                        _telefono.text =
                                                                            '';
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _showThankYouDialog(
                                                                            context);
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        elevation:
                                                                            MaterialStateProperty.all(8),
                                                                        surfaceTintColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Aceptar",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000),
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(1),
                                        minimumSize: MaterialStatePropertyAll(
                                            Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.28,
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    0, 106, 252, 1.000)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Retirar dinero",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: largoActual * (80 / 760),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  //color: Colors.amberAccent,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Lottie.asset(
                                    'lib/imagenes/billetera1.json'),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              //CONFIGURACION
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.045),
                    child: Text(
                      "Configuración",
                      style: TextStyle(
                          color: colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: largoActual * (16 / 760)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se debe ver la info de notificaciones del cliente
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: colorInhabilitado,
                              size: anchoActual * 0.065,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Notificaciones',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se puede va a implementar el libro de reclamaciones
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: anchoActual * 0.065,
                              color: colorInhabilitado,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Libro de reclamaciones',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se puede agregar la informacion de la tienda
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: anchoActual * 0.065,
                              color: colorInhabilitado,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Registra tu tienda',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  //CERRAR SESION
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('user');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              size: anchoActual * 0.065,
                              color: colorLetra,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Cerrar sesion',
                              style: TextStyle(
                                  color: colorLetra,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.exit_to_app_rounded,
                          color: colorLetra,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ]),
      )),
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gracias'),
          content: Text(
              'Se realizará el depósito mediante el método de pago que eligió dentro del plazo de una semana'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
