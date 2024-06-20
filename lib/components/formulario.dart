import 'dart:convert';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/provider/user_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Formu extends StatefulWidget {
  const Formu({super.key});

  @override
  State<Formu> createState() => _FormuState();
}

class _FormuState extends State<Formu> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nombres = TextEditingController();
  final TextEditingController _apellidos = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  bool _obscureText = true;
  String? selectedSexo;
  List<String> sexos = ['Masculino', 'Femenino'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCreateUser = '/api/user_cliente';

  Future<dynamic> registrar(nombre, apellidos, dni, sexo, fecha, fechaAct,
      nickname, contrasena, email, telefono, ruc) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });
    try {
      // Parsear la fecha de nacimiento a DateTime
      DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fecha);

      // Formatear la fecha como una cadena en el formato deseado (por ejemplo, 'yyyy-MM-dd')
      String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);
      String fechaActual = DateFormat('yyyy-MM-dd').format(fechaAct);

      await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email,
            "nombre": nombre,
            "apellidos": apellidos,
            "telefono": telefono,
            "ruc": ruc ?? "",
            "dni": dni,
            "fecha_nacimiento": fechaFormateada,
            "fecha_creacion_cuenta": fechaActual,
            "sexo": sexo,
            "direccion_empresa": "NA",
            "suscripcion": "Básico",
            "nombre_empresa": "NA",
            "frecuencia": "NA",
            "quiereretirar": false,
            "medio_retiro": "NA",
            "banco_retiro": "NA",
            "numero_cuenta": "NA"
          }));
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final TabController _tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    double largoCasilla = largoActual * 0.068;
    double tamanoLabel = largoActual * 0.018;
    double tamanoHint = largoActual * 0.018;
    DateTime tiempoActual = DateTime.now();
    Color textoIngreso = Color.fromARGB(255, 84, 84, 84);
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
        body: DecoratedBox(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromRGBO(0, 106, 252, 1.000),
        Color.fromRGBO(0, 106, 252, 1.000),
        Colors.white,
      ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
      child: SafeArea(
          top: false,
          child: Padding(
              padding: EdgeInsets.only(
                top: largoActual * 0.05,
                left: anchoActual * 0.02,
                right: anchoActual * 0.02,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TITULOS
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10 * 0.013, left: 10 * 0.055),
                      //color:Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          SizedBox(
                            width: anchoActual * 0.02,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  child: Text(
                                "Nos encantaría",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: largoActual * 0.025,
                                    fontWeight: FontWeight.w600),
                              )),
                              Container(
                                  child: Text(
                                "saber de ti",
                                style: TextStyle(
                                    fontSize: largoActual * 0.025,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              )),
                            ],
                          ),
                          Expanded(child: Container()),
                          Container(
                            margin: EdgeInsets.only(right: anchoActual * 0.025),
                            height: (largoActual * 0.094),
                            width: (largoActual * 0.094),
                            child: Lottie.asset('lib/imagenes/pelotita.json'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: largoActual * 0.01,
                    ),

                    // FORMULARIO
                    Container(
                      //margin: EdgeInsets.only(left: anchoActual * 0.055),
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10),
                      // height: 700,
                      width: anchoActual * 0.9,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 1.5,
                            color: Color.fromARGB(255, 163, 163, 163),
                          )),
                      //color:Colors.cyan,
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _nombres,
                                  decoration: InputDecoration(
                                    labelText: 'Nombres',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: false,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _apellidos,
                                  decoration: InputDecoration(
                                    labelText: 'Apellidos',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _dni,
                                  decoration: InputDecoration(
                                    labelText: 'DNI',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: DropdownButtonFormField<String>(
                                  value: selectedSexo,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSexo = value;
                                    });
                                  },
                                  items: sexos.map((sexo) {
                                    return DropdownMenuItem<String>(
                                      value: sexo,
                                      child: Text(sexo),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Sexo',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  readOnly: true,
                                  controller:
                                      _fechaController, // Usa el controlador de texto
                                  onTap: () async {
                                    // Abre el selector de fechas cuando se hace clic en el campo
                                    DateTime? fechaSeleccionada =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime(2101),
                                    );

                                    if (fechaSeleccionada != null) {
                                      // Actualiza el valor del campo de texto con la fecha seleccionada
                                      _fechaController.text =
                                          "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
                                    }
                                  },
                                  keyboardType: TextInputType.datetime,

                                  keyboardAppearance: Brightness.light,
                                  style: TextStyle(
                                    fontSize: tamanoLabel,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Fecha de Nacimiento',
                                    // hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _username,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _password,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintText: 'Ingrese una contraseña',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla * 1.3,
                                child: TextFormField(
                                  controller: _telefono,
                                  maxLength: 9,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla,
                                child: TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Ingresa su email',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    } else if (value != null &&
                                        !(value.contains('@gmail.com') ||
                                            value.contains('@hotmail.com'))) {
                                      return 'No es un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: largoCasilla * 1.3,
                                child: TextFormField(
                                  controller: _ruc,
                                  maxLength: 11,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'RUC (opcional)',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: tamanoLabel,
                                      fontWeight: FontWeight.w500,
                                      color: textoIngreso,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: tamanoHint,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),

                    // REGISTRAR
                    SizedBox(
                      height: largoActual * 0.031,
                    ),
                    SizedBox(
                      //margin: EdgeInsets.only(left: anchoActual * 0.055),
                      height: largoActual * 0.06,
                      width: anchoActual * 0.42,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await registrar(
                                _nombres.text,
                                _apellidos.text,
                                _dni.text,
                                selectedSexo,
                                _fechaController.text,
                                tiempoActual,
                                _username.text,
                                _password.text,
                                _email.text,
                                _telefono.text,
                                _ruc.text);
                            // USUARIO NUEVO PARA CONTROL DE BIDON
                           /* setState(() {
                              userProvider.user?.esNuevo = true;
                            });*/

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
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
                          "Registrar",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 106, 252, 1.000),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: largoActual * 0.031,
                    ),
                  ],
                ),
              ))),
    ));
  }
}
