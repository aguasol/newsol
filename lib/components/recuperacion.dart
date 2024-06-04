import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsol_final/components/update.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Recuperacion extends StatefulWidget {
  const Recuperacion({super.key});
  @override
  State<Recuperacion> createState() => _RecuperacionState();
}

class _RecuperacionState extends State<Recuperacion> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  int status = 0;
  Future<dynamic> registrar(String info) async {
    try {
      SharedPreferences registroid = await SharedPreferences.getInstance();
      var res =
          await http.post(Uri.parse(apiUrl + '/api/user_cliente/Recovery'),
              headers: {"Content-type": "application/json"},
              body: jsonEncode({
                "info": info,
              }));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        registroid.setInt('key', data['id']);
        setState(() {
          status = res.statusCode;
        });
      } else if (res.statusCode == 401) {
        setState(() {
          status = res.statusCode;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          status = res.statusCode;
        });
      } else if (res.statusCode == 500) {
        setState(() {
          status = res.statusCode;
        });
      } else {
        throw Exception("Codigo de estado desconocido ${res.statusCode}");
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restablecer contraseña"),
        backgroundColor: Colors.blue, // Establecer el color de fondo del AppBar
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Introduce tu nombre de usuario o correo o número de teléfono",
              ),
              SizedBox(height: 7),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Usuario o correo o número de teléfono',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa usuario o correo o número de teléfono';
                  }
                  // You can add more validation for email format if needed
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (_formKey.currentState!.validate()) {
                      await registrar(_emailController.text);
                      if (status == 200) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Newpass()),
                        );
                      } else if (status == 401) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Row(
                                children: [
                                  SizedBox(width: 20),
                                  Text("Intente de nuevo"),
                                ],
                              ),
                            );
                          },
                        );
                      } else if (status == 404) {
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
                      } else if (status == 500) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Row(
                                children: [
                                  SizedBox(width: 20),
                                  Text("Usuario no asociado"),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  } catch (e) {
                    throw Exception("error de servidor $e");
                  }
                },
                child: Text('Recuperar Contraseña'),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(8),
                  surfaceTintColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
