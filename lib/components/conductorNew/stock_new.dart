import 'package:appsol_final/components/holaconductor2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';

class ActualizadoStock extends StatefulWidget {
  const ActualizadoStock({
    Key? key,
  }) : super(key: key);

  @override
  State<ActualizadoStock> createState() => _ActualizadoStockState();
}

class _ActualizadoStockState extends State<ActualizadoStock> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedidoRuta/';
  String apiStock = '/api/vehiculo_producto_conductor/';
  String apiDetalleVehiculo = '/api/vehiculo_producto/';
  String mensaje =
      'El día de hoy todavía no te han asignado una ruta, espera un momento ;)';
  bool puedoLlamar = false;
  bool puedoPasarAHola2 = false;

  int numerodePedidosExpress = 0;
  List<Pedido> listPedidosbyRuta = [];
  List<Producto> listProducto = [];
  bool tengoruta = false;
  Color colorProgreso = Colors.transparent;
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);
  Color colorTexto = const Color.fromARGB(255, 75, 75, 75);
  int rutaID = 0;
  int? rutaIDpref = 0;
  int? vehiculoIDpref = 0;
  int montoRuta = 0;
  int stockMinFaltnte = 0;
  int? conductorIDpref = 0;
  int cantidad = 0;
  List<int> idpedidos = [];
  List<DetallePedido> listDetallePedido = [];

  //CREAR UN FUNCION QUE LLAME EL ENDPOINT EN EL QUE SE VERIFICA QUE EL CONDUCTOR
  //TIENE UNA RUTA ASIGNADA PARA ESE DÍA
  Future<dynamic> updateStock(stock, productoID) async {
    try {
      await http.put(Uri.parse(apiUrl + apiStock + vehiculoIDpref.toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode(
              {"stock_movil_conductor": stock, "producto_id": productoID}));
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<dynamic> getProductosVehiculo() async {
    if (vehiculoIDpref != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetalleVehiculo + vehiculoIDpref.toString()),
        headers: {"Content-type": "application/json"},
      );
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['id'],
              productoID: mapa['producto_id'],
              productoNombre: '',
              cantidadProd: mapa['stock'],
              promocionID: 0,
              promocionNombre: '',
            );
          }).toList();

          for (var j = 0; j < listProducto.length; j++) {
            for (var i = 0; i < listTemporal.length; i++) {
              if (listProducto[j].id == listTemporal[i].productoID) {
                setState(() {
                  listProducto[j].cantidadActual =
                      listProducto[j].cantidadActual +
                          listTemporal[i].cantidadProd;
                });
              }
            }
            setState(() {
              listProducto[j].cantidadFaltante =
                  listProducto[j].cantidadRequeridaParaRuta -
                      listProducto[j].cantidadActual;
            });
          }
          setState(() {
            listProducto.sort((element2, element1) => (element1.cantidadFaltante
                .compareTo(element2.cantidadFaltante)));
          });
          for (var j = 0; j < listProducto.length; j++) {
            if (listProducto[j].cantidadFaltante <= 0) {
              //sobran  productos
              setState(() {
                listProducto[j].tesobraTefalta = 'Stock sobrante:';
                listProducto[j].signo = '+';
                listProducto[j].cantidadFaltante =
                    listProducto[j].cantidadFaltante * (-1);
                listProducto[j].colorFaltaoSobra =
                    const Color.fromRGBO(83, 176, 68, 1.000);
              });
            }
          }
        }
      } catch (e) {
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      //print('no corrriooo');
    }
  }

  Future<dynamic> getProductosRuta() async {
    //print('----------------------------------');
    //print('3) Dentro de productos rutaaaaaa');
    //print('ruta ID: $rutaIDpref');
    if (rutaIDpref != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + rutaIDpref.toString()),
        headers: {"Content-type": "application/json"},
      );
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['pedido_id'],
              productoID: mapa['producto_id'],
              productoNombre: mapa['nombre_prod'],
              cantidadProd: mapa['cantidad'],
              promocionID: mapa['promocion_id'],
              promocionNombre: mapa['nombre_prom'],
            );
          }).toList();
          setState(() {
            for (var j = 0; j < listProducto.length; j++) {
              for (var i = 0; i < listTemporal.length; i++) {
                if (listProducto[j].nombre == listTemporal[i].productoNombre) {
                  setState(() {
                    listProducto[j].cantidadRequeridaParaRuta =
                        listProducto[j].cantidadRequeridaParaRuta +
                            listTemporal[i].cantidadProd;
                  });
                }
              }
            }
          });
        }
      } catch (e) {
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      //print('no corrrioooooo');
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
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
            cantidadStock: TextEditingController(),
            cantidadActual: 0,
            cantidadRequeridaParaRuta: 0,
          );
        }).toList();

        if (mounted) {
          tempProducto.removeWhere((element) => (element.id == 6));
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

  _cargarPreferencias() async {
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    SharedPreferences vehiculoPreference =
        await SharedPreferences.getInstance();
    if (rutaPreference.getInt("Ruta") != null) {
      setState(() {
        rutaIDpref = rutaPreference.getInt("Ruta");
      });
    } else {
      setState(() {
        rutaIDpref = 1;
      });
    }
    if (userPreference.getInt("userID") != null) {
      setState(() {
        conductorIDpref = userPreference.getInt("userID");
      });
    } else {
      setState(() {
        conductorIDpref = 3;
      });
    }
    if (vehiculoPreference.getInt("carID") != null) {
      setState(() {
        vehiculoIDpref = vehiculoPreference.getInt("carID");
      });
    } else {
      setState(() {
        vehiculoIDpref = 1;
      });
    }
  }

  Future<void> _initialize() async {
    await _cargarPreferencias();
    await getProducts();
    await getProductosRuta();
    await getProductosVehiculo();
  }

  void dialogo(titulo, largo, contenido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            titulo,
            style: TextStyle(
                fontSize: largo * 0.026,
                fontWeight: FontWeight.w400,
                color: Colors.black),
          ),
          content: Text(
            contenido,
            style:
                TextStyle(fontSize: largo * 0.018, fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el AlertDialog
              },
              child: Text(
                'OK',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: largo * 0.02,
                    color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    conductorIDpref = userProvider.user?.id;
    //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        //key: _scaffoldKey,
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
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
          Colors.white,
          Colors.white,
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
        child: SafeArea(
            top: true,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: largoActual * 0.03,
                      ),
                      //MENSAJE DE ACTUALIZA TU STOCK O ALGO ASÍ
                      Text(
                        'Actualiza tu stock',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: largoActual * 0.04),
                      ),
                      SizedBox(
                        height: largoActual * 0.01,
                      ),
                      //LISTVIEW BUILDER QUE CREE TEXT FROM FIELD
                      SizedBox(
                        height: largoActual * 0.75,
                        width: anchoActual,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: listProducto.length,
                            itemBuilder: (context, index) {
                              Producto producto = listProducto[index];

                              return Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                elevation: 8,
                                margin: EdgeInsets.only(
                                    left: anchoActual * 0.03,
                                    right: anchoActual * 0.03,
                                    bottom: largoActual * 0.006,
                                    top: largoActual * 0.006),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //CONTAINER DE LA FOTO DEL PRODUCTO
                                    Container(
                                      height: largoActual * 0.085,
                                      width: anchoActual * 0.085,
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(producto.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    //DESCRIPCION DEL PRODUCTO
                                    Container(
                                      width: anchoActual * 0.42,
                                      height: largoActual * 0.129,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //NOMBRE DEL PRODUCTO
                                          Text(
                                            producto.nombre.capitalize(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: largoActual * 0.019,
                                                color: const Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          //CUANTOS TIENES, CUANTOS NECESITAS, CUANTOAS TE FALTAN PARA
                                          //CUMPLIR CON TU RUTA
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Stock actual: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                              Text(
                                                producto.cantidadActual
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Stock requerido: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                              Text(
                                                producto
                                                    .cantidadRequeridaParaRuta
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                producto.tesobraTefalta,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        largoActual * 0.0168,
                                                    color: producto
                                                        .colorFaltaoSobra),
                                              ),
                                              Text(
                                                "${producto.signo}${producto.cantidadFaltante.toString()}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        largoActual * 0.018,
                                                    color: producto
                                                        .colorFaltaoSobra),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    //AREA PARA INGRESAR LA CANTIDAD QUE ESTAS AÑADIENDO AL CARRO

                                    SizedBox(
                                      width: anchoActual * 0.16,
                                      child: TextFormField(
                                        controller: producto.cantidadStock,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+'))
                                        ],
                                        style: TextStyle(
                                            fontSize: largoActual * 0.03),
                                        cursorColor: const Color.fromRGBO(
                                            0, 106, 252, 1.000),
                                        enableInteractiveSelection: false,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) {
                                          // SETEAR DE LA LISTA MIXTA(PROD Y PROMO)
                                          setState(() {
                                            producto.cantidadStock.text = value;
                                          });
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              producto.cantidad = int.parse(
                                                  producto.cantidadStock.text);
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255,
                                              244,
                                              244,
                                              244), // Cambia este color según tus preferencias

                                          hintText: '0',
                                          disabledBorder: InputBorder.none,

                                          hintStyle: TextStyle(
                                              fontSize: largoActual * 0.03),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      //ESPACIOSSS

                      //BOTON DE ACTUALIZAR
                      SizedBox(
                          child: ElevatedButton(
                              onPressed: () async {
                                //print("YAAAAAAAAAAAAAAAAA");
                                for (var i = 0; i < listProducto.length; i++) {
                                  var cantidad =
                                      listProducto[i].cantidadStock.text;
                                  if (listProducto[i].signo == '') {
                                    if (cantidad.isEmpty) {
                                      //faltan producto
                                      dialogo('Falta llenar', largoActual,
                                          'Por favor, actualiza los datos en los productos con "Stock faltante", con estos datos podrás hacer tu cierre de ventas más facil ;)');
                                    } else {
                                      if (int.parse(cantidad) <
                                          listProducto[i].cantidadFaltante) {
//faltan producto
                                        dialogo('Ups!', largoActual,
                                            'La cantidad de Stock que subas al carro, debe ser mayor o igual al Stock faltante para que puedas cumplir tu ruta');
                                      } else {
                                        setState(() {
                                          puedoPasarAHola2 = true;
                                        });
                                      }
                                    }
                                  }
                                }
                                if (puedoPasarAHola2) {
                                  for (var j = 0;
                                      j < listProducto.length;
                                      j++) {
                                    Producto producto = listProducto[j];

                                    if (producto.cantidad > 0) {
                                      await updateStock(
                                          producto.cantidad +
                                              producto.cantidadActual,
                                          producto.id);
                                      SharedPreferences actualizadoStock =
                                          await SharedPreferences.getInstance();
                                      actualizadoStock.setBool(
                                          "actualizado", true);
                                    }
                                  }
                                  //print("PASARRRR");
                                  Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HolaConductor2()
                                        //const Promos()
                                        ),
                                  );
                                }
                              },
                              style: ButtonStyle(
                                surfaceTintColor: MaterialStateProperty.all(
                                    Color.fromRGBO(83, 176, 68, 1.000)),
                                elevation: MaterialStateProperty.all(10),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.054)),
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromRGBO(83, 176, 68, 1.000)),
                              ),
                              child: Text(
                                '¡Listo!',
                                style: TextStyle(
                                    fontSize: largoActual * 0.021,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ))),
                      SizedBox(
                        height: largoActual * 0.04,
                      ),
                    ],
                  ),
                ))),
      ),
    ));
  }
}
