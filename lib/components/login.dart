import 'package:appsol_final/components/formulario.dart';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/ubicacion.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl/intl.dart';
import 'package:appsol_final/components/recuperacion.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText1 = true;
  double opacity = 0.0;
  String apiLogin = '/api/login';
  String apiLastPedido = '/api/pedido_last/';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  late int status = 0;
  late int rol = 0;
  late int id = 0;
  late UserModel userData;
  bool yaTieneUbicaciones = false;
  bool noTienePedidosEsNuevo = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth __auth = FirebaseAuth.instance;
  String apiCreateUser = '/api/user_cliente';
  String rolIdKey = "rol_id";
  String nicknameKey = "nickname";
  String contrasenaKey = "contrasena";
  String emailKey = "email";
  String nombreKey = "nombre";
  String apellidosKey = "apellidos";
  String telefonoKey = "telefono";
  String rucKey = "ruc";
  String dniKey = "dni";
  String fechaNacimientoKey = "fecha_nacimiento";
  String fechaCreacionCuentaKey = "fecha_creacion_cuenta";
  String sexoKey = "sexo";
  String numrecargas = "";

  Future<dynamic> getBidonCliente(clienteID) async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + '/api/clientebidones/' + clienteID.toString()),
        headers: {"Content-type": "application/json"},
      );
      SharedPreferences bidonCliente = await SharedPreferences.getInstance();

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        print("data si hay bidon o no");
        print(data);
        if (data == null) {
          print("no hay dta");
          setState(() {
            bidonCliente.setBool('comproBidon', false);
          });
        } else {
          print("si hay data");
          setState(() {
            bidonCliente.setBool('comproBidon', true);
          });
        }
      }
    } catch (e) {
      throw Exception("Error ${e}");
    }
  }

  Future<User?> _signInWithFacebook() async {
    try {
      // Iniciar sesión con Facebook
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Obtener el token de acceso de Facebook
      final AccessToken accessToken = loginResult.accessToken!;

      // Crear una credencial de autenticación de Facebook
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      // Iniciar sesión con Firebase
      final UserCredential userCredential =
          await __auth.signInWithCredential(credential);

      // Obtener el usuario actual
      final User? user = userCredential.user;

      if (user != null) {
        // El usuario ha iniciado sesión correctamente
        print('Usuario autenticado: ${user.displayName}');
        return user;
      } else {
        print('Error al iniciar sesión con Facebook');
      }
    } catch (e) {
      print('Error al iniciar sesión con Facebook: $e');
    }
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
    } catch (error) {
      print("Esta aqui: $error");
      return null;
    }
  }

  Future<dynamic> registrar(
      String? nombre,
      String? fecha,
      fechaAct,
      String? nickname,
      String? contrasena,
      String? email,
      String? telefono) async {
    try {
      await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email,
            "nombre": nombre,
            "apellidos": '',
            "telefono": telefono ?? '',
            "ruc": '',
            "dni": '',
            "fecha_nacimiento": fecha,
            "fecha_creacion_cuenta": fechaAct,
            "sexo": ''
          }));
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  void initState() {
    super.initState();
    //getUsers();
    // Iniciar la animación de la opacidad después de 500 milisegundos
    Timer(Duration(milliseconds: 900), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  Future<dynamic> recargas(clienteID) async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + '/api/cliente/recargas/' + clienteID.toString()),
        headers: {"Content-type": "application/json"},
      );
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data != null) {
          setState(() {
            numrecargas = data['recargas'];
          });
        } else {
          setState(() {
            numrecargas = '0';
          });
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> loginsol(username, password) async {
    try {
      print("------loginsool");
      print(username);

      var res = await http.post(Uri.parse(apiUrl + apiLogin),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"nickname": username, "contrasena": password}));
      print("why");
      print(res);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        // CLIENTE

        if (data['usuario']['rol_id'] == 4) {
          print("dentro del cliente");
          print("userDataCopy");
          SharedPreferences userDataCopy =
              await SharedPreferences.getInstance();
          userDataCopy.setString('token', data['token']);
          userDataCopy.setInt('idcopy', data['usuario']['id']);
          userDataCopy.setString('nombrecopy', data['usuario']['nombre']);
          userDataCopy.setString('apellidoscopy', data['usuario']['apellidos']);
          userDataCopy.setDouble('saldoBeneficiocopy',
              data['usuario']['saldo_beneficios'].toDouble() ?? 0.00);
          userDataCopy.setString(
              'codigoclientecopy', data['usuario']['codigo'] ?? 'Sin código');
          print("codigo-----------------------------");
          print(data['usuario']['codigo']);
          userDataCopy.setString('fechaCreacionCuentacopy',
              data['usuario']['fecha_creacion_cuenta']);
          userDataCopy.setString('sexocopy', data['usuario']['sexo']);
          userDataCopy.setString(
              'frecuenciacopy', data['usuario']['frecuencia']);
          userDataCopy.setBool(
              'quiereRetirarcopy', data['usuario']['quiereretirar']);
          userDataCopy.setString('suscripcioncopy',
              data['usuario']['suscripcion'] ?? 'Sin suscripción');
          print(userDataCopy);
          print("-----------------------------------------------------------");
          print("cli");
          print("userData");
          // data['usuario']['nombre']
          print(data['usuario']['id']);
          await recargas(data['usuario']['id']);
         // await getBidonCliente(data['usuario']['id']);
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos'],
              saldoBeneficio:
                  data['usuario']['saldo_beneficios'].toDouble() ?? 0.00,
              codigocliente: data['usuario']['codigo'] ?? 'Sin código',
              fechaCreacionCuenta: data['usuario']['fecha_creacion_cuenta'],
              sexo: data['usuario']['sexo'],
              frecuencia: data['usuario']['frecuencia'],
              quiereRetirar: data['usuario']['quiereretirar'],
              suscripcion: data['usuario']['suscripcion'] ?? 'Sin suscripción',
              token: data['token'],
              rolid: data['usuario']['rol_id'],
              recargas: numrecargas);
          print(userData);
          print("-----------------------------------------------------------");
          setState(() {
            status = 200;
            rol = 4;
            id = userData.id!;
          });
        }
        //CONDUCTOR
        else if (data['usuario']['rol_id'] == 5) {
          print("conductor");
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombres'],
              apellidos: data['usuario']['apellidos'],
              rolid: data['usuario']['rol_id']);

          setState(() {
            status = 200;
            rol = 5;
            id = userData.id!;
          });
        }
        // GERENTE
        else if (data['usuario']['rol_id'] == 3) {
          print("gerente");
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos'],
              rolid: data['usuario']['rol_id']);

          setState(() {
            status = 200;
            rol = 3;
            id = userData.id!;
          });
        }

        // ACTUALIZAMOS EL ESTADO DEL PROVIDER, PARA QUE SE PUEDA USAR DE MANERA GLOBAL
        Provider.of<UserProvider>(context, listen: false).updateUser(userData);
        SharedPreferences userPreference =
            await SharedPreferences.getInstance();
        userPreference.setInt("userID", id);
        print(id);
      } else if (res.statusCode == 401) {
        var data400 = json.decode(res.body);
        print("data400");
        print(data400);
        setState(() {
          status = 401;
        });
      } else if (res.statusCode == 404) {
        var data404 = json.decode(res.body);
        print("data 404");
        print(data404);
        setState(() {
          status = 404;
        });
      } else {
        throw Exception("Codigo de estado desconocido ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Excepcion $e");
    }
  }

  Future<dynamic> tieneUbicaciones(clienteID) async {
    print("-------get ubicaciones---------");
    print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("-------entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<UbicacionModel> tempUbicacion = data.map<UbicacionModel>((mapa) {
          return UbicacionModel(
              id: mapa['id'],
              latitud: mapa['latitud'].toDouble(),
              longitud: mapa['longitud'].toDouble(),
              direccion: mapa['direccion'],
              clienteID: mapa['cliente_id'],
              clienteNrID: null,
              distrito: mapa['distrito'],
              zonaID: mapa['zona_trabajo_id']);
        }).toList();
        setState(() {
          if (tempUbicacion.isEmpty) {
            print("${tempUbicacion.length}");
            //NOT TIENE UBIS
            yaTieneUbicaciones = false;
          } else {
            //SI TIENE UBISSS
            yaTieneUbicaciones = true;
          }
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> tienePedidos(clienteID) async {
    print("-------get pedidossss---------");
    var res = await http.get(
      Uri.parse(apiUrl + apiLastPedido + clienteID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("-------entro al try de get pedidossss---------");
        var data = json.decode(res.body);
        print(data);
        if (data == null) {
          setState(() {
            noTienePedidosEsNuevo = true;
          });
        } else {
          setState(() {
            noTienePedidosEsNuevo = false;
          });
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.white,
            Color.fromRGBO(0, 106, 252, 1.000),
            Color.fromRGBO(0, 106, 252, 1.000),
          ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LOGO SOL
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 30, left: 20),
                      height: MediaQuery.of(context).size.height / 8,
                      width: MediaQuery.of(context).size.width / 2.25,
                      child: Opacity(
                          opacity: 1,
                          child: Image.asset(
                              'lib/imagenes/logo_aguasol_blanco.png')),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // FORMULARIO
                  Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _usuario,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  labelText: 'Usuario o email o celular',
                                  hintText: 'Ingrese credenciales',
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese su usuario';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _contrasena,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText1,
                                decoration: InputDecoration(
                                  labelText: 'Ingrese Contraseña',
                                  hintText: 'Ingrese sus credenciales',
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText1 = !_obscureText1;
                                      });
                                    },
                                    child: Icon(
                                      _obscureText1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese una contraseña';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                      margin: EdgeInsets.only(left: 120),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Recuperacion()),
                            );
                          },
                          child: Text(
                            "¿Olvidaste contraseña?",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ))),

                  Center(
                    child: Container(
                      width: 500,
                      margin:
                          const EdgeInsets.only(top: 0, left: 20, right: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          print(largoActual);
                          print(anchoActual);
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                });
                            try {
                              await loginsol(_usuario.text, _contrasena.text);

                              if (status == 200) {
                                Navigator.of(context)
                                    .pop(); // Cerrar el primer AlertDialog

                                //SI ES CLIENTE
                                if (rol == 4) {
                                  await tieneUbicaciones(userData.id);
                                  await tienePedidos(userData.id);
                                  if (noTienePedidosEsNuevo) {
                                    setState(() {
                                      userData.esNuevo = true;
                                    });
                                  } else {
                                    setState(() {
                                      userData.esNuevo = false;
                                    });
                                  }
                                  //SI YA TIENE UBICACIONES INGRESA DIRECTAMENTE A LA BARRA DE AVEGACION
                                  if (yaTieneUbicaciones == true) {
                                    print("YA tiene unibicaciones");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BarraNavegacion(
                                                  indice: 0, subIndice: 0)),
                                    );
                                    //SI NO TIENE UBICACIONES INGRESA A UBICACION
                                  } else {
                                    print("NO tiene unibicaciones");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Ubicacion()),
                                    );
                                  }

                                  //SI ES CONDUCTOR
                                } else if (rol == 5) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HolaConductor()),
                                  );

                                  //SI ES GERENTE
                                } else if (rol == 3) {
                                  //por cmabiar
                                }
                                //SI NO ESTA REGISTRADO
                              } else if (status == 401) {
                                Navigator.of(context)
                                    .pop(); // Cerrar el primer AlertDialog

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Row(
                                        children: [
                                          SizedBox(width: 20),
                                          Text("Credenciales inválidas"),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else if (status == 404) {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Row(
                                        children: [
                                          SizedBox(width: 20),
                                          Text("Usuario no existente"),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print(
                                  "Excepción durante el inicio de sesión: $e");
                            }
                          }
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(8),
                          surfaceTintColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        child: const Text(
                          "Ingresa",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 106, 252, 1.000),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      width: 800,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          print(largoActual);
                          print(anchoActual);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Formu()),
                          );
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(0, 106, 252, 1.000))),
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
/*
                  Center(
                    child: const Center(
                        child: Text(
                      "o continua con:",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                  ),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final User? user = await _signInWithGoogle();
                              if (user != null) {
                                await loginsol(
                                    user.displayName, user.displayName);
                                while (status != 200) {
                                  await registrar(
                                      user.displayName,
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now()),
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now()),
                                      user.displayName,
                                      user.displayName,
                                      user.email,
                                      user.phoneNumber);
                                  await loginsol(
                                      user.displayName, user.displayName);
                                }
                                await tieneUbicaciones(userData.id);
                                await tienePedidos(userData.id);
                                if (noTienePedidosEsNuevo) {
                                  setState(() {
                                    userData.esNuevo = true;
                                  });
                                } else {
                                  setState(() {
                                    userData.esNuevo = false;
                                  });
                                }
                                //SI YA TIENE UBICACIONES INGRESA DIRECTAMENTE A LA BARRA DE AVEGACION
                                if (yaTieneUbicaciones == true) {
                                  print("YA tiene unibicaciones");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BarraNavegacion(
                                                indice: 0, subIndice: 0)),
                                  );
                                  //SI NO TIENE UBICACIONES INGRESA A UBICACION
                                } else {
                                  print("NO tiene unibicaciones");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Ubicacion()),
                                  );
                                }
                              } else {
                                print('Error al iniciar sesión con Google');
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'lib/imagenes/google.png',
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text("Iniciar sesión")
                              ],
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
