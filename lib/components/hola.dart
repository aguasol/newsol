import 'dart:math';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/ubicaciones_lista_model.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:lottie/lottie.dart';
import 'package:appsol_final/models/zona_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Producto {
  final String nombre;
  final double precio;
  final String descripcion;

  final String foto;

  Producto(
      {required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.foto});
}

class Hola2 extends StatefulWidget {
  final String? url;
  final String? loggedInWith;
  final int? clienteId;
  final bool? esNuevo;
  //final double? latitud;
  // final double? longitud;

  const Hola2({
    this.url,
    this.loggedInWith,
    this.clienteId,
    this.esNuevo,
    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);

  @override
  State<Hola2> createState() => _HolaState();
}

class _HolaState extends State<Hola2> with TickerProviderStateMixin {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiZona = '/api/zona';
  List<Producto> listProducto = [];
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  int? zonaIDUbicacion = 0;
  int? clienteID = 0;
  bool? yaSeMostro = false;
  List<UbicacionModel> listUbicacionesObjetos = [];
  List<String> ubicacionesString = [];
  String? _ubicacionSelected;
  late String? dropdownValue;
  late String? distrito;
  int cantCarrito = 0;
  double ganacia = 3.00;
  Color colorCantidadCarrito = Colors.black;
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  late String direccionNueva;
  late UbicacionModel miUbicacion;
  late UbicacionModel miUbicacionNueva;
  List<Zona> listZonas = [];
  List<String> tempString = [];
  Map<int, dynamic> mapaLineasZonas = {};
  //ACA SE DEBE ACTUALIZAR LA IMAGEN PARA COMPARTIR EN LOS ESTADOS
  String direccionImagenParaEstados = 'lib/imagenes/12-so-dscto-AGUA-SOL.png';
  //ACA SE DEBE ACTUALIZAR EL LINK PARA DESCARGAR LA APPPPPP
  String urlPreview = 'https://www.youtube.com/shorts/ombROZ2VXb4';
  String urlExplicacion = 'https://www.youtube.com/shorts/ombROZ2VXb4';
  String tituloUbicacion = 'Gracias por compartir tu ubicación!';
  String contenidoUbicacion = '¡Disfruta de Sol Market!';
  List<String> listPromociones = [];

  //bool _disposed = false;
  //bool _autoScrollInProgress = false;

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  DateTime fechaLimite = DateTime.now();

  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      return DateTime.parse(fecha);
    } else {
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
  }

  @override
  void initState() {
    super.initState();
    ordenarFuncionesInit();
  }

  Future<void> muestraDialogoPubli(BuildContext context) async {
    SharedPreferences yasemostroPubli = await SharedPreferences.getInstance();
    yasemostroPubli.setBool("ya", true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var codigo = userProvider.user?.codigocliente;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      // color: Colors.green,
                      width: MediaQuery.of(context).size.width / 1.3,
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                              padding: EdgeInsets.all(6),
                              margin: EdgeInsets.only(right: 0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.blue,
                                Colors.blue.shade300,
                                Colors.blue.shade200,
                                Colors.yellow.shade100,
                                Colors.white,
                                Colors.blue.shade100
                              ])),
                              width: 370,
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      RichText(
                                              text: TextSpan(
                                                  text:
                                                      '\n Sabías\n que\n puedes \n ganar\n dinero con ...',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              20,
                                                      color: Colors.white)))
                                          .animate()
                                          .fade(),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        child: Image.asset(
                                            "lib/imagenes/logo_aguasol_splash.png"),
                                      )
                                    ],
                                  ),
                                  Text(
                                    "Descubre \ncomo hacerlo !",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width*0.085,
                                        fontWeight: FontWeight.w300,
                                        color: const Color.fromARGB(
                                            255, 7, 91, 161)),
                                  ).animate().shake(),
                                  Center(
                                    child: Container(
                                      
                                        width:
                                            MediaQuery.of(context).size.width / 2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                7,
                                        child: Center(
                                            child: Image.asset(
                                                "lib/imagenes/mujer.png"))),
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(6),
                              margin: EdgeInsets.only(right: 0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.blue,
                                Colors.blue.shade300,
                                Colors.blue.shade200,
                                Colors.yellow.shade100,
                                Colors.white
                              ])),
                              width: 370,
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                              text: TextSpan(
                                                  text:
                                                      '\n\nAcumula\ndinero en tu\nbilletera SOL',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              20,
                                                      color: Color.fromARGB(
                                                          255, 226, 227, 226))))
                                          .animate()
                                          .fade(),
                                      Container(
                                        decoration: BoxDecoration(
                                        
                                        
                                          image: DecorationImage(
                                            image: AssetImage("lib/imagenes/amigso.png"),
                                            fit: BoxFit.cover
                                          )
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5.5,
                                       
                                      )
                                    ],
                                  ),
                                  Text(
                                    "Comparte tu código\n${codigo}\ncon tus amigos! =)",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width*0.06,
                                        fontWeight: FontWeight.w600,
                                        color: const Color.fromARGB(
                                            255, 7, 91, 161)),
                                  ).animate().shake(),
                                  Text("* Recuerda que también puedes compartirlo desde la billetera sol *",style: TextStyle(
                                    color: const Color.fromARGB(255, 3, 76, 135),fontSize: MediaQuery.of(context).size.width*0.023
                                  ),),
                                  Center(
                                    child: Container(
                                      
                                        width:
                                            MediaQuery.of(context).size.width / 2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                7.5,
                                                decoration: BoxDecoration(
                                                  
                                                  image: DecorationImage(
                                                    image: AssetImage("lib/imagenes/wallet.png"),
                                                    fit: BoxFit.contain)
                                                ),
                                        ),
                                  )
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Colors.blue,
                              Colors.blue.shade300,
                              Colors.yellow.shade100,
                              Colors.white
                            ])),
                            width: 370,
                            height: 70,
                            child: Column(
                              children: [
                                Text(
                                  "\n\nPuedes usar el código de un amigo para gozar de un descuento, en la compra de un bidón de 20L\n",
                                  style: GoogleFonts.josefinSans(
                                      fontSize: 20, color: Colors.white),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: codigo,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Colors.blue,
                              Colors.blue.shade300,
                              Colors.yellow.shade100,
                              Colors.white
                            ])),
                            width: 370,
                            height: 70,
                            child: Column(
                              children: [
                                Text(
                                  "\n\nTambién puedes gozar de un descuenteo en la compra de tu primer bidón de 20L\n",
                                  style: GoogleFonts.josefinSans(
                                      fontSize: 20, color: Colors.white),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: codigo,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -MediaQuery.of(context).size.width / 3.5,
                      left: -MediaQuery.of(context).size.width / 9,
                      child: Container(
                        // color: Colors.yellow,
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.height / 5,
                        child: Image.asset('lib/imagenes/BIDON20.png'),
                      ).animate().fade().shake(),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.width,
                      right: MediaQuery.of(context).size.width / 3.5,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(85)),
                          width: MediaQuery.of(context).size.width / 7,
                          height: MediaQuery.of(context).size.height / 15,
                          child: Lottie.asset("lib/imagenes/manita_left.json")),
                    ),
                    Positioned(
                        top: MediaQuery.of(context).size.height / 3,
                        left: 50,
                        child: Container(
                          height: 300,
                          width: 300,
                          child: Lottie.asset("lib/imagenes/ganaste.json"),
                        ))
                  ],
                ));
          });
    });
  }

  _cargarPreferencias() async {
    SharedPreferences yasemostroPubli = await SharedPreferences.getInstance();
    if (yasemostroPubli.getBool("ya") != null) {
      setState(() {
        yaSeMostro = yasemostroPubli.getBool("ya");
      });
    } else {
      setState(() {
        yaSeMostro = false;
      });
    }
  }

  Future<void> ordenarFuncionesInit() async {
    await _cargarPreferencias();
    await getUbicaciones(widget.clienteId);
    await getProducts();
    await getZonas();
    await getPromociones();
    if (widget.esNuevo != null &&
        widget.esNuevo == true &&
        yaSeMostro == false) {
      await muestraDialogoPubli(context);
    } else {
      print("+++++++++++++++++++++++++++++++++++++++++");
      print(widget.esNuevo);
    }
  }

  Future<void> nuevaUbicacion() async {
    await creadoUbicacion(widget.clienteId, distrito);
    await getUbicaciones(widget.clienteId);
  }

  Future<dynamic> getZonas() async {
    var res = await http.get(
      Uri.parse(apiUrl + apiZona),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Zona> tempZona = data.map<Zona>((mapa) {
          return Zona(
            id: mapa['id'],
            nombre: mapa['nombre'],
            poligono: mapa['poligono'],
            departamento: mapa['departamento'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            listZonas = tempZona;
          });
          for (var i = 0; i < listZonas.length; i++) {
            setState(() {
              tempString = listZonas[i].poligono.split(',');
            });
            //el string 'poligono', se separa en strings por las comas en la lista
            //temString
            for (var j = 0; j < tempString.length; j++) {
              //luego se recorre la lista y se hacen puntos con cada dos numeros
              if (j % 2 == 0) {
                //es multiplo de dos
                //SI ES PAR
                double x = double.parse(tempString[j]);
                double y = double.parse(tempString[j + 1]);
                //print('$x y $y');
                setState(() {
                  //print('entro al set Statw');
                  listZonas[i].puntos.add(Point(x, y));
                });
              }
            }
            //print('se llenaron los puntos de esta zona');
            //print(listZonas[i].puntos);
          }

          //AHORA DE ACUERDO A LA CANTIDAD DE PUTNOS QUE HAY EN LA LISTA DE PUNTOS SE CALCULA LA CANTIDAD
          //DE LINEAS CON LAS QUE S ETRABAJA
          for (var i = 0; i < listZonas.length; i++) {
            //print('entro al for que revisa zona por zona');
            var zonaID = listZonas[i].id;
            //print('esta en la ubicación = $i, con zona ID = $zonaID');
            setState(() {
              //print(
              //  'se crea la key zon ID, con un valor igual a un mapa vacio');
              mapaLineasZonas[zonaID] = {};
            });

            for (var j = 0; j < listZonas[i].puntos.length; j++) {
              //ingresa a un for en el que se obtienen los datos de todas la lineas que forman los puntos del polígono
              if (j == listZonas[i].puntos.length - 1) {
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[0];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };

                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              } else {
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[j + 1];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };

                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getUbicaciones(clienteID) async {
    setState(() {
      listUbicacionesObjetos = [];
      ubicacionesString = [];
    });
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get ubicaciones---------");
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
              zonaID: mapa['zona_trabajo_id'] ?? 0);
        }).toList();
        if (mounted) {
          setState(() {
            listUbicacionesObjetos = tempUbicacion;
          });
          for (var i = 0; i < listUbicacionesObjetos.length; i++) {
            setState(() {
              ubicacionesString.add(listUbicacionesObjetos[i].direccion);
            });
          }
          UbicacionListaModel listUbis = UbicacionListaModel(
              listaUbisObjeto: listUbicacionesObjetos,
              listaUbisString: ubicacionesString);
          Provider.of<UbicacionListProvider>(context, listen: false)
              .updateUbicacionList(listUbis);
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getPromociones() async {
    var res = await http.get(
      Uri.parse('$apiUrl/api/promocion'),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<String> tempPromocion = data.map<String>((mapa) {
          return '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}';
        }).toList();

        if (mounted) {
          setState(() {
            listPromociones = tempPromocion;
          });
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
    await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccionNueva,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
          "zona_trabajo_id": zonaIDUbicacion
        }));
  }

  Future<void> obtenerDireccion(x, y) async {
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        setState(() {
          direccionNueva =
              "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
          setState(() {
            distrito = lugar.locality;
          });
        });
      } else {
        direccionNueva = "Default";
      }
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
        int suma = 0;
        for (UbicacionModel ubi in listUbicacionesObjetos) {
          if (ubi.direccion != direccionNueva) {
            //son diferentesssss
            suma += 0;
          } else {
            //son iguales
            suma += 1;
          }
        }
        if (suma == 0) {
          //no es igual a ninguna direccion existente
          nuevaUbicacion();
        } else {
          //es igual a una direccion, por lo tanto no se agrega nada
        }
      });
    }
  }

  Future<void> currentLocation() async {
    print("¡¡Entro al CurrectLocation!!");
    var location = location_package.Location();
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

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
    // Verificar si el servicio de ubicación está habilitado
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
    }

    // Obtener la ubicación
    try {
      locationData = await location.getLocation();

      //updateLocation(locationData);
      await obtenerDireccion(locationData.latitude, locationData.longitude);

      //print("ubicación - $locationData");
      //print("latitud - $latitudUser");
      //print("longitud - $longitudUser");

      // Aquí puedes utilizar la ubicación obtenida (locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
    }
  }

  Future puntoEnPoligono(double? xA, double? yA) async {
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
            //print('- Cumple todas estas');
            //print('- $xA <= ${mapaLinea["maxX"]}');
            //print('- ${mapaLinea['minY']} <= $yA');
            //print('- $yA<= ${mapaLinea['maxY']}');
            //print('');
            var xInterseccion =
                (yA - mapaLinea['constante']) / mapaLinea['pendiente'];
            /*print('Se calcula la xInterseccion');
            print(
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
              //print(zonaIDUbicacion);
            });
            //es impar ESTA AFUERA
            break;
          }
        } else {
          setState(() {
            zonaIDUbicacion = null;
          });
        }
      }
    }
  }

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        // VERIFICAR SI EL WIDGET EXISTE Y LUEGO SETEAMOS EL VALOR
        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      cantCarrito = pedido.cantidadProd;
      if (pedido.cantidadProd > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      setState(() {
        cantCarrito = 0;
        colorCantidadCarrito = Colors.grey;
      });
    }
  }

  void direccionesVacias() {
    if (listUbicacionesObjetos.isEmpty) {
      setState(() {
        dropdownValue = "";
      });
    } else {
      setState(() {
        dropdownValue = listUbicacionesObjetos.first.direccion;
        miUbicacion = listUbicacionesObjetos.first;
      });
    }
  }

  UbicacionModel direccionSeleccionada(String direccion) {
    UbicacionModel ubicacionObjeto = UbicacionModel(
        id: 0,
        latitud: 0,
        longitud: 0,
        direccion: 'direccion',
        clienteID: 0,
        clienteNrID: 0,
        distrito: 'distrito',
        zonaID: 0);
    for (var i = 0; i < listUbicacionesObjetos.length; i++) {
      if (listUbicacionesObjetos[i].direccion == direccion) {
        setState(() {
          ubicacionObjeto = listUbicacionesObjetos[i];
        });
      }
    }
    return ubicacionObjeto;
  }
  // TEST UBICACIONES PARA DROPDOWN

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    String mensajeCodigoParaAmigos =
        'Hola!,\nTe presento la *app 💧 Sol Market 💧* usa mi codigo para tu primera compra de un *BIDÓN DE AGUA DE 20L (bidon + agua)* y te lo podrás llevar *a solo S/.23.00 ~(Precio regular: S/.35.00)~*.\n¡Solo usando mi código!.\nAdemás puedes referir a tus contactos con tu codigo y _*beneficiarte con S/. 3.00 💸*_ por las compras que realicen. \n✅ USA MI CODIGO DE REFERENCIA: ${userProvider.user?.codigocliente}\n❓ Más detalles AQUÍ: $urlExplicacion \n⏬ Descarga la APP AQUÍ: $urlPreview';
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final pedidoProvider = context.watch<PedidoProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    direccionesVacias();
    esVacio(pedidoProvider.pedido);
    return Scaffold(
        backgroundColor: Colors.white,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: SafeArea(
              key: _scaffoldKey,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //CONTAINER DE UBICACION Y CARRITO
                        Container(
                          width: anchoActual,

                          //color: Colors.red,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //LOCATION
                              Container(
                                width: MediaQuery.of(context).size.width / 1.3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    //BOTON DE AGREGAR UBI
                                    Container(
                                      width: anchoActual * 0.13,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 230, 213, 57),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    0, 106, 252, 1.000),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                    top: largoActual * 0.041,
                                                    left: anchoActual * 0.055,
                                                    right: anchoActual * 0.055),
                                                height: largoActual * 0.17,
                                                width: anchoActual,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        'Agregar Ubicación',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              largoActual *
                                                                  0.023,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: largoActual *
                                                            0.013),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await currentLocation();

                                                        // ignore: use_build_context_synchronously
                                                        Navigator.pop(
                                                            // ignore: use_build_context_synchronously
                                                            context);
                                                        // ignore: use_build_context_synchronously
                                                        Navigator.pop(
                                                            // ignore: use_build_context_synchronously
                                                            context);
                                                      },
                                                      style: ButtonStyle(
                                                        surfaceTintColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(8),
                                                        minimumSize:
                                                            MaterialStatePropertyAll(
                                                                Size(
                                                                    anchoActual *
                                                                        0.28,
                                                                    largoActual *
                                                                        0.054)),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                      ),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .add_location_alt_rounded,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000),
                                                              size:
                                                                  largoActual *
                                                                      0.034,
                                                            ),
                                                            Text(
                                                              ' Agregar ubicación actual',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      largoActual *
                                                                          0.021,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      106,
                                                                      252,
                                                                      1.000)),
                                                            ),
                                                          ]),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                            Icons.add_location_alt_outlined,
                                            size: largoActual * 0.031,
                                            color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      width: anchoActual * 0.005,
                                    ),
                                    //BOTON DE LISTA DE UBIS
                                    Container(
                                      width: anchoActual * 0.63,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            83, 176, 68, 1.000),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        //color: Colors.amberAccent,
                                        margin: const EdgeInsets.only(
                                            left: 12, right: 5),
                                        child: DropdownButton<String>(
                                          hint: Text(
                                            '¿A dónde llevamos tu pedido?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: largoActual * 0.018,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: largoActual * 0.018,
                                              fontWeight: FontWeight.w500),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          elevation: 20,
                                          dropdownColor: const Color.fromRGBO(
                                              83, 176, 68, 1.000),
                                          isExpanded: true,
                                          value: _ubicacionSelected,
                                          items: ubicacionesString
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue is String) {
                                              if (direccionSeleccionada(
                                                          newValue)
                                                      .zonaID ==
                                                  0) {
                                                setState(() {
                                                  tituloUbicacion =
                                                      'Lo sentimos :(';
                                                  contenidoUbicacion =
                                                      'Todavía no llegamos a tu zona, pero puedes revisar nuestros productos en la aplicación o elegir otra ubicación :D';
                                                });
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      title: Text(
                                                        tituloUbicacion,
                                                        style: TextStyle(
                                                            fontSize:
                                                                largoActual *
                                                                    0.026,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      content: Text(
                                                        contenidoUbicacion,
                                                        style: TextStyle(
                                                            fontSize:
                                                                largoActual *
                                                                    0.018,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Cierra el AlertDialog
                                                          },
                                                          child: Text(
                                                            'OK',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    largoActual *
                                                                        0.02,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                setState(() {
                                                  _ubicacionSelected = newValue;
                                                  miUbicacion =
                                                      direccionSeleccionada(
                                                          newValue);
                                                });
                                                Provider.of<UbicacionProvider>(
                                                        context,
                                                        listen: false)
                                                    .updateUbicacion(
                                                        miUbicacion);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().shakeX(
                                    duration: Duration(milliseconds: 300),
                                  ),

                              //CARRITO
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        0, 106, 252, 1.000),
                                    borderRadius: BorderRadius.circular(50)),
                                height: largoActual * 0.059,
                                width: largoActual * 0.059,
                                child: Badge(
                                  largeSize: 18,
                                  backgroundColor: colorCantidadCarrito,
                                  label: Text(cantCarrito.toString(),
                                      style: const TextStyle(fontSize: 12)),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Pedido()
                                            //const Promos()
                                            ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.shopping_cart_rounded),
                                    color: Colors.white,
                                    iconSize: largoActual * 0.030,
                                  ).animate().shakeY(
                                        duration: Duration(milliseconds: 300),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //BIENVENIDA DEL CLIENTE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // color: Colors.amber,
                                  //width: anchoActual,
                                  margin: EdgeInsets.only(
                                      left: anchoActual * 0.055,
                                      top: largoActual * 0.016,
                                      right: 20),
                                  child: Text(
                                    "Bienvenid@, ${userProvider.user?.nombre?.capitalize()}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: largoActual * 0.019,
                                        color: colorLetra),
                                  ),
                                ),
                                Container(
                                  //color: Colors.purple,
                                  margin: EdgeInsets.only(
                                      left: anchoActual * 0.055),
                                  child: Text(
                                    "Disfruta de Sol Market!",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: largoActual * 0.019,
                                        color: colorTextos),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  //color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20)),
                              child: IconButton(
                                iconSize: 5,
                                icon: Image(
                                    image: AssetImage("lib/imagenes/info.png")),
                                onPressed: () async {
                                  await muestraDialogoPubli(context);
                                },
                              ),
                            ).animate().shake().fade()
                          ],
                        ),

                        SizedBox(
                          height: largoActual * 0.016,
                        ),
                        //TAB BAR PRODUCTOS/PROMOCIONES
                        SizedBox(
                          height: largoActual * 0.046,
                          width: anchoActual,
                          child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              controller: _tabController,
                              indicatorWeight: 10,
                              /*indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(120, 251, 99, 0.5),
                              ),*/
                              labelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight
                                      .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                              unselectedLabelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight.w300),
                              labelColor: colorTextos,
                              unselectedLabelColor: colorTextos,
                              indicatorColor:
                                  const Color.fromRGBO(83, 176, 68, 1.000),
                              tabs: const [
                                Tab(
                                  text: "Promociones",
                                ),
                                Tab(
                                  text: "Productos",
                                ),
                              ]),
                        ),
                        //IMAGENES DE PRODUCTOS Y PROMOCIONES TAB BAR
                        Container(
                          margin: EdgeInsets.only(
                            top: largoActual * 0.013,
                          ),
                          height: largoActual / 2.5,
                          width: double.maxFinite,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ListView.builder(
                                  controller: scrollController1,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: listPromociones.length,
                                  itemBuilder: (context, index) {
                                    String promo = listPromociones[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 1,
                                                  )),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image: NetworkImage(promo),
                                              fit: BoxFit.fitHeight,
                                            )),
                                      ),
                                    );
                                  }),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BarraNavegacion(
                                              indice: 0,
                                              subIndice: 2,
                                            )
                                        //const Productos()
                                        ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: anchoActual * 0.028),
                                  height: anchoActual * 0.83,
                                  width: anchoActual * 0.83,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 130, 219, 133),
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "$apiUrl/images/bodegon.jpg"),
                                          fit: BoxFit.cover)),
                                ),
                              )
                              /*
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController2,
                                  itemCount: listProducto.length,
                                  itemBuilder: (context, index) {
                                    Producto producto = listProducto[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 2,
                                                  )
                                              //const Productos()
                                              ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(producto.foto),
                                              fit: BoxFit.fitHeight,
                                            )),
                                      ),
                                    );
                                  }),*/
                            ],
                          ),
                        ),
                        //Expanded(child: Container()),
                        SizedBox(
                          height: largoActual * 0.03,
                        ),
                        //BILLETERA SOL
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.055),
                          child: Text(
                            "Billetera Sol",
                            style: TextStyle(
                                color: colorTextos,
                                fontWeight: FontWeight.w500,
                                fontSize: largoActual * 0.019),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.009,
                        ),
                        SizedBox(
                          height: largoActual * 0.14,
                          child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  surfaceTintColor: Colors.white,
                                  color: Colors.yellow,
                                  elevation: 10,
                                  child: OutlinedButton(
                                    style: const ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                        ),
                                        side: MaterialStatePropertyAll(
                                            BorderSide.none)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierColor:
                                              Colors.black.withOpacity(0.8),
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              insetPadding: EdgeInsets.all(
                                                0,
                                              ),
                                              backgroundColor:
                                                  Colors.transparent,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              child: Stack(
                                                  clipBehavior: Clip.none,
                                                  alignment: Alignment.center,
                                                  children: [
                                                    //CONTAINER CON INFO DE LA PROMOOO
                                                    Container(
                                                      height:
                                                          largoActual * 0.64,
                                                      width: anchoActual * 0.8,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          gradient: const LinearGradient(
                                                              colors: [
                                                                Color.fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                                Color.fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                                Color.fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                                Color.fromRGBO(
                                                                    150,
                                                                    198,
                                                                    230,
                                                                    1),
                                                                Colors.white,
                                                                Colors.white,
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomCenter)),
                                                      child: Container(
                                                        margin: EdgeInsets.all(
                                                            anchoActual * 0.06),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            //ESPACIO PARA QUE EL TEXTO NO SE TAPE CON LAS IMAGENES
                                                            SizedBox(
                                                              height:
                                                                  largoActual *
                                                                      0.15,
                                                            ),
                                                            //TEXTO QUIERES GANAR MONI
                                                            Text(
                                                              '¿Quieres ganar dinero sin salir de tu hogar?',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      largoActual *
                                                                          0.03,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            //TEXTO CON AGUA SOL PUEDES LOGRARLO
                                                            Text(
                                                              '¡Con Sol Market puedes lograrlo!',
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      largoActual *
                                                                          0.025,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                            //ESPACIOOO
                                                            SizedBox(
                                                                height:
                                                                    largoActual *
                                                                        0.04),
                                                            //TEXTO EXPLICATIVO
                                                            RichText(
                                                                text: TextSpan(
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .normal,
                                                                        color:
                                                                            colorLetra,
                                                                        fontSize:
                                                                            largoActual *
                                                                                0.021,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    children: [
                                                                  const TextSpan(
                                                                      text:
                                                                          'Puedes '),
                                                                  TextSpan(
                                                                      text:
                                                                          'GANAR S/. ${ganacia}0 ',
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w800)),
                                                                  const TextSpan(
                                                                      text:
                                                                          'por cada '),
                                                                  const TextSpan(
                                                                      text:
                                                                          'Bidon Nuevo ',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w800)),
                                                                  const TextSpan(
                                                                      text:
                                                                          'que '),
                                                                  const TextSpan(
                                                                      text:
                                                                          'compren ',
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          fontWeight:
                                                                              FontWeight.w800)),
                                                                  const TextSpan(
                                                                      text:
                                                                          'tus contactos con tu código: '),
                                                                  TextSpan(
                                                                      text:
                                                                          '${userProvider.user?.codigocliente}.',
                                                                      style: const TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          fontWeight:
                                                                              FontWeight.w800)),
                                                                ])),
                                                            SizedBox(
                                                              height:
                                                                  largoActual *
                                                                      0.007,
                                                            ),
                                                            RichText(
                                                                text: TextSpan(
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .normal,
                                                                        color:
                                                                            colorLetra,
                                                                        fontSize:
                                                                            largoActual *
                                                                                0.017,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    children: const [
                                                                  TextSpan(
                                                                    text:
                                                                        'Recuerda que tu código tiene una válidez de ',
                                                                  ),
                                                                  TextSpan(
                                                                      text:
                                                                          '3 meses ',
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          fontWeight:
                                                                              FontWeight.w800)),
                                                                  TextSpan(
                                                                      text:
                                                                          'desde que creaste tu cuenta.'),
                                                                ])),

//ESPACIOOO
                                                            SizedBox(
                                                                height:
                                                                    largoActual *
                                                                        0.04),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      largoActual *
                                                                          (17 /
                                                                              740),
                                                                  child: ElevatedButton(
                                                                      style: const ButtonStyle(
                                                                          elevation: MaterialStatePropertyAll(10),
                                                                          surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                          backgroundColor: MaterialStatePropertyAll(Colors.white),
                                                                          shape: MaterialStatePropertyAll(
                                                                            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                          ),
                                                                          side: MaterialStatePropertyAll(BorderSide.none)),
                                                                      onPressed: () async {
                                                                        await Share.share(mensajeCodigoParaAmigos +
                                                                            urlPreview);
                                                                      },
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.share,
                                                                              size: largoActual * 0.02,
                                                                              color: colorTextos),
                                                                          SizedBox(
                                                                              width: anchoActual * 0.02),
                                                                          Text(
                                                                            'COMPARTE TU CÓDIGO',
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.normal,
                                                                                color: colorTextos,
                                                                                fontSize: largoActual * 0.015,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        largoActual *
                                                                            0.01),
                                                                //BOTON PARA PUBLICARLO EN TU ESTADO
                                                                SizedBox(
                                                                  height:
                                                                      largoActual *
                                                                          (17 /
                                                                              760),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: const ButtonStyle(
                                                                        elevation: MaterialStatePropertyAll(10),
                                                                        surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                                                                        shape: MaterialStatePropertyAll(
                                                                          RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                        ),
                                                                        side: MaterialStatePropertyAll(BorderSide.none)),
                                                                    onPressed:
                                                                        () async {
                                                                      final image =
                                                                          await rootBundle
                                                                              .load(direccionImagenParaEstados);
                                                                      final buffer =
                                                                          image
                                                                              .buffer;
                                                                      final temp =
                                                                          await getTemporaryDirectory();
                                                                      final path =
                                                                          '${temp.path}/image.jpg';

                                                                      await Share
                                                                          .shareXFiles(
                                                                        [
                                                                          XFile
                                                                              .fromData(
                                                                            buffer.asUint8List(
                                                                              image.offsetInBytes,
                                                                              image.lengthInBytes,
                                                                            ),
                                                                            mimeType:
                                                                                'jpg',
                                                                            name:
                                                                                'usaMiCodigo',
                                                                          )
                                                                        ],
                                                                        subject:
                                                                            'mi codigo',
                                                                      );
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .share,
                                                                          size: largoActual *
                                                                              0.02,
                                                                          color:
                                                                              colorTextos,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              anchoActual * 0.02,
                                                                        ),
                                                                        Text(
                                                                          'PUBLÍCALO EN TU ESTADO',
                                                                          style: TextStyle(
                                                                              fontStyle: FontStyle.normal,
                                                                              color: colorTextos,
                                                                              fontSize: largoActual * 0.015,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
//BOTON COMPARTE
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    //ANIMACION PALMERAS
                                                    Positioned(
                                                      top: -largoActual * 0.08,
                                                      left: anchoActual * 0.035,
                                                      height:
                                                          largoActual * 0.23,
                                                      child: Lottie.asset(
                                                          'lib/imagenes/palmeras1.json'),
                                                    ),

                                                    //ANIMACION PLAYERA
                                                    Positioned(
                                                      top: -largoActual * 0.08,
                                                      left: anchoActual * 0.035,
                                                      height:
                                                          largoActual * 0.23,
                                                      child: Lottie.asset(
                                                          'lib/imagenes/playa1.json'),
                                                    ),
                                                    //ANIMACION PALMERAS
                                                    Positioned(
                                                      top: -largoActual * 0.08,
                                                      left: anchoActual * 0.18,
                                                      height:
                                                          largoActual * 0.23,
                                                      child: Lottie.asset(
                                                          'lib/imagenes/palmeras1.json'),
                                                    ),

                                                    //IMAGEN DE BIDONCITO BONITO
                                                    Positioned(
                                                      top: -largoActual * 0.15,
                                                      right:
                                                          -anchoActual * 0.08,
                                                      child: Container(
                                                        height:
                                                            largoActual * 0.30,
                                                        width:
                                                            anchoActual * 0.5,
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        decoration: const BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            image: DecorationImage(
                                                                image: AssetImage(
                                                                    'lib/imagenes/BIDON20.png'),
                                                                fit: BoxFit
                                                                    .scaleDown)),
                                                      ),
                                                    ),
                                                    //BOTON DE CERRADO
                                                    Positioned(
                                                      top: -largoActual * 0.13,
                                                      right:
                                                          -anchoActual * 0.018,
                                                      child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  11,
                                                                  191,
                                                                  191,
                                                                  191),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                          height: largoActual *
                                                              0.05,
                                                          width: largoActual *
                                                              0.05,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const Pedido()
                                                                    //const Promos()
                                                                    ),
                                                              );
                                                            },
                                                            icon: const Icon(Icons
                                                                .close_rounded),
                                                            color: Colors.white,
                                                            iconSize:
                                                                largoActual *
                                                                    0.030,
                                                          )),
                                                    ),
                                                  ]),
                                            );
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'S/. ${userProvider.user?.saldoBeneficio}0',
                                              style: TextStyle(
                                                  color: colorLetra,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 35),
                                            ),
                                            Text(
                                              'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                              style: TextStyle(
                                                  color: colorLetra,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize:
                                                      largoActual * 0.016),
                                            ),
                                          ],
                                        ),
                                        Lottie.asset(
                                            'lib/imagenes/billetera3.json'),
                                      ],
                                    ),
                                  ))
                              .animate()
                              .shake(duration: Duration(milliseconds: 700)),
                        ),
                      ]))),
        ));
  }
}
