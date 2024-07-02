import 'dart:math';
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

class Permiso extends StatefulWidget {
  const Permiso({super.key});

  @override
  State<Permiso> createState() => _PermisoState();
}

class _PermisoState extends State<Permiso> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiZona = '/api/zona';
  bool _isloading = false;
  int? zonaIDUbicacion = 0;
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  String tituloUbicacion = 'Gracias por compartir tu ubicación!';
  String contenidoUbicacion = '¡Disfruta de Agua Sol!';
  int? clienteID = 0;
  late String direccion;
  late String? distrito;
  List<Zona> listZonas = [];
  List<String> tempString = [];
  Map<int, dynamic> mapaLineasZonas = {};
  @override
  void initState() {
    super.initState();
  }

/*
  Future<void> _showlocationpermissiondialogo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Se necesita acceso a la ubicación en segundo plano'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Esta aplicación requiere acceso a la ubicación en segundo plano para funcionar correctamente.'),
                SizedBox(height: 10),
                Text(
                    'Por favor, habilite el acceso de ubicación, en la configuración de su dispositivo.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await currentLocation();
              },
            ),
          ],
        );
      },
    );
  }*/
  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
    await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccion,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
          "zona_trabajo_id": zonaIDUbicacion
        }));
  }

  Future puntoEnPoligono(double? xA, double? yA) async {
    /*print('----------------------------------------');
    print('----------------------------------------');
    print('¡¡ENTRO A PUNTO EN POLIGONO!!');*/
    if (xA is double && yA is double) {
      //print('1) son double, se recorre las zonas');
      for (var i = 0; i < listZonas.length; i++) {
        var zonaID = listZonas[i].id;
        //print('zonaID = $zonaID');
        mapaLineasZonas[zonaID].forEach((value, mapaLinea) {
          //print('Ingreso a recorrer las lineas de la zona $zonaID');
          if (xA <= mapaLinea["maxX"] &&
              mapaLinea['minY'] <= yA &&
              yA <= mapaLinea['maxY']) {
            /*print('- Cumple todas estas');
            print('- $xA <= ${mapaLinea["maxX"]}');
            print('- ${mapaLinea['minY']} <= $yA');
            print('- $yA<= ${mapaLinea['maxY']}');
            print('');*/
            var xInterseccion =
                (yA - mapaLinea['constante']) / mapaLinea['pendiente'];
           // print('Se calcula la xInterseccion');
            /*print(
                'xI = ($yA - ${mapaLinea['constante']})/${mapaLinea['pendiente']} = $xInterseccion');*/
            if (xA <= xInterseccion) {
              //EL PUNTO INTERSECTA A LA LINEA
              /*print('- el punto intersecta la linea hacia la deresha');
              print('- $xA <= $xInterseccion');
              print('');*/
              setState(() {
                mapaLinea['intersecciones'] = 1;
              });
            }
          }
        });
      }
      //SE CUENTA LA CANTIDAD DE INTERSECCIONES EN CADA ZONA
      for (var i = 0; i < listZonas.length; i++) {
        //se revisa para cada zona
        /*print('');
        print('');
        print('Ahora se cuenta la cantidad de intersecciones');*/
        var zonaID = listZonas[i].id;
        //print('Primero en la zona $zonaID');
        int intersecciones = 0;
        mapaLineasZonas[zonaID].forEach((key, mapaLinea) {
          if (mapaLinea['intersecciones'] == 1) {
            intersecciones += 1;
          }
        });
        if (intersecciones > 0) {
          //print('Nª intersecciones = $intersecciones en la Zona $zonaID');
          if (intersecciones % 2 == 0) {
            //print('- Es una cantidad PAR, ESTA AFUERA');
            setState(() {
              zonaIDUbicacion = null;
            });
          } else {
            setState(() {
              //print('- Es una cantidad IMPAR, ESTA DENTRO');
              zonaIDUbicacion = zonaID;
              print(zonaIDUbicacion);
            });
            //es impar ESTA AFUERA
            break;
          }
        } else {
          //print('No tiene intersecciones');
          setState(() {
            zonaIDUbicacion = null;
          });
          //print('');
        }
      }
    }
  }

  Future<void> obtenerDireccion(x, y) async {
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        setState(() {
          direccion =
              "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
          setState(() {
            distrito = lugar.locality;
          });
        });
      } else {
        direccion = "Default";
      }
      /*print("x-----y");
      print("${x},${y}");*/
      await puntoEnPoligono(x, y);
    } catch (e) {
      //throw Exception("Error ${e}");
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error de Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: const Text(
              'Hubo un problema al obtener la ubicación. Por favor, inténtelo de nuevo.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el AlertDialog
                  setState(() {
                    _isloading = false;
                  });
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        latitudUser = x;
        longitudUser = y;
        _isloading = false;
        //print('esta es la zonaID $zonaIDUbicacion');
        creadoUbicacion(clienteID, distrito);
        if (zonaIDUbicacion == null) {
          setState(() {
            tituloUbicacion = 'Lo sentimos :(';
            contenidoUbicacion =
                'Todavía no llegamos a tu zona, pero puedes revisar nuestros productos en la aplicación :D';
          });
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Text(
                tituloUbicacion,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              content: Text(
                contenidoUbicacion,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el AlertDialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BarraNavegacion(
                                indice: 0,
                                subIndice: 0,
                              )),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 25,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> currentLocation() async {
    var location = location_package.Location();
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

    /*setState(() {
      _isloading = true;
    });*/

    // Verificar si el servicio de ubicación está habilitado
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        /*setState(() {
          _isloading = true;
        });*/
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        Navigator.of(context).pop();
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
      Navigator.of(context).pop();
    }

    // Obtener la ubicación
    try {
      locationData = await location.getLocation();

      //updateLocation(locationData);
      await obtenerDireccion(locationData.latitude, locationData.longitude);

     // print("----ubicación--");
      //print(locationData);
      //print("----latitud--");
      //print(latitudUser);
      //print("----longitud--");
      //print(longitudUser);

      // Aquí puedes utilizar la ubicación obtenida (locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      //print("Error al obtener la ubicación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Icon(
            Icons.location_on_outlined,
            size: 45,
            color: Colors.blueAccent,
          ),
          Container(
            margin: EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Usa tu ubicación",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: "Para asegurar entregas precisas, "),
                        TextSpan(
                          text:
                              "permita que AguaSol use tu ubicación todo el tiempo.",
                          style: TextStyle(
                            // Resalta el texto en negrita
                            color: Colors
                                .black, // Puedes cambiar el color según tus preferencias
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "AguaSol recopila datos de ubicación para habilitar el rastreo en tiempo real del reparto, notificaciones de entrega y programación de entregas incluso cuando la aplicación está cerrada o no se está utilizando.",
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.amber,
                      image: DecorationImage(
                        image: AssetImage('lib/imagenes/pngegg.png'),
                        fit: BoxFit.cover, // O ajusta según tus necesidades
                      ),
                    ),
                    // Aquí puedes colocar el resto de tu contenido
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "Denegar",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                        TextButton(
                            onPressed: () async {
                              await currentLocation();
                            },
                            child: Text("Aceptar",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
