import 'dart:math';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/models/zona_model.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/components/permiso.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newpass extends StatefulWidget {
  const Newpass({super.key});

  @override
  State<Newpass> createState() => _NewpassState();
}

class _NewpassState extends State<Newpass> {
  TextEditingController _pass = TextEditingController();
  TextEditingController _newpass = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureText1 = true;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  Future<dynamic> RecPassword(int id, String clave) async {
    try {
      var res = await http.put(
          Uri.parse(apiUrl + '/api/user_cliente/Recovery/' + id.toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({'clave': clave}));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 21, 90, 146),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Por favor ingresa una nueva contraseña.",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: _pass,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscureText1,
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            hintText: 'Crea una nueva contraseña',
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            hintStyle:
                                TextStyle(fontSize: 20, color: Colors.grey),
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
                      Container(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: _newpass,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Repetir Contraseña',
                            hintText: 'Confirme contraseña',
                            labelStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 20,
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
                    ],
                  ),
                ),
                Container(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_pass.text != _newpass.text) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        size: 15,
                                        color: Colors.amberAccent,
                                      ),
                                      Text(
                                        "Las contraseñas deben ser iguales!",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            SharedPreferences registroid =
                                await SharedPreferences.getInstance();
                            int? id = registroid.getInt('key');
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
                            await RecPassword(id!, _newpass.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.greenAccent)),
                      child: Text(
                        "Cambiar contraseña",
                        style: TextStyle(color: Colors.black),
                      )),
                )
              ]),
        )));
  }
}
