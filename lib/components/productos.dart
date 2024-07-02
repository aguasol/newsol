import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/promocion_model.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  late PedidoModel pedidoMio;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiProductos = "/api/products";
  List<Producto> listProducto = [];
  bool almenosUno = false;
  List<Producto> productosProvider = [];
  List<Promo> promosProvider = [];
  double totalProvider = 0.0;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  double envio = 0.0;
  //EL AHORRO ES IGUAL A 4 SOLES POR CADA BIDON NUEVO

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse(apiUrl + apiProductos),
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
          );
        }).toList();

        if (mounted) {
          setState(() {
            tempProducto.removeWhere((element) => (element.id == 6));
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void obtenerProductos() async {
    List<Producto> listTemp = productosProvider +
        listProducto.where((product) => product.cantidad > 0).toList();
    var seen = <String>{};
    List<Producto> uniquelist =
        listTemp.where((product) => seen.add(product.nombre)).toList();

    setState(() {
      productosProvider = uniquelist;
    });

    //SE CALCULA EL TOTAL DE PRODUCTOS YPROMOSSSS
    double totalpromos = 0;
    double totalproductos = 0;
    for (var promos in promosProvider) {
      totalpromos += promos.cantidad * promos.precio;
    }
    for (var product in productosProvider) {
      totalproductos += product.cantidad * product.precio;
    }
    setState(() {
      totalProvider = totalpromos + totalproductos;
    });
  }

  // FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      almenosUno = true;
      listProducto[index].cantidad++;
    });
  }

  void disminuir(int index) {
    if (listProducto[index].cantidad > 0) {
      setState(() {
        listProducto[index].cantidad--;
      });
    }
    almenosUno =
        listProducto.where((producto) => producto.cantidad > 0).isNotEmpty;
  }

  double obtenerTotal() {
    double stotal = 0;

    List productosContabilizados =
        listProducto.where((producto) => producto.cantidad > 0).toList();

    for (var producto in productosContabilizados) {
      stotal += producto.cantidad * producto.precio;
    }

    return stotal;
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      //print('ES PEDIDOOO');
      productosProvider = pedido.seleccionados;
      promosProvider = pedido.seleccionadosPromo;
      cantCarrito = productosProvider.length + promosProvider.length;
      envio = pedido.envio;
      if (cantCarrito > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      //print('no es pedido');
      setState(() {
        cantCarrito = 0;
        productosProvider = [];
        promosProvider = [];
        colorCantidadCarrito = Colors.grey;
        totalProvider = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = obtenerTotal();
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = context.watch<PedidoProvider>();
    esVacio(pedidoProvider.pedido);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: largoActual * 0.08,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: anchoActual * 0.15,
                  margin: EdgeInsets.only(top: largoActual * 0.018),
                  child: Text(
                    'VER CARRITO',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: colorTextos,
                        fontSize: largoActual * 0.015,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: anchoActual * 0.02,
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: largoActual * 0.018, right: anchoActual * 0.045),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 106, 252, 1.000),
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
                          MaterialPageRoute(builder: (context) => const Pedido()
                              //const Promos()
                              ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_rounded),
                      color: Colors.white,
                      iconSize: largoActual * 0.030,
                    ).animate().shakeY(
                          duration: Duration(milliseconds: 300),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: largoActual * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: anchoActual * 0.055),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Nuestros Productos",
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 1, 42, 76),
                                    fontWeight: FontWeight.w200,
                                    fontSize: largoActual * 0.026),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(left: anchoActual * 0.055),
                                //color:Colors.grey,
                                //height:100,
                                child: Text(
                                  "están hechos para ti!",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 1, 46, 84),
                                      fontSize: largoActual * 0.025,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //CONTAINER DE LISTBUILDER
                    SizedBox(
                      height: largoActual * 0.58,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listProducto.length,
                          itemBuilder: (context, index) {
                            Producto producto = listProducto[index];
                            return Card(
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              elevation: 8,
                              margin: EdgeInsets.only(
                                  top: largoActual * 0.027,
                                  left: anchoActual * 0.028,
                                  right: anchoActual * 0.028,
                                  bottom: largoActual * 0.041),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: largoActual * 0.3125,
                                    width: anchoActual * 0.5,
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(producto.foto),
                                            fit: BoxFit.scaleDown)),
                                  ),
                                  Container(
                                    width: anchoActual * 0.55,
                                    height: largoActual * 0.148,
                                    //color: Colors.grey,
                                    margin: EdgeInsets.only(
                                        top: largoActual * 0.013,
                                        right: anchoActual * 0.028,
                                        left: anchoActual * 0.028),
                                    child: Column(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          producto.nombre.capitalize(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: largoActual * 0.02,
                                              color: const Color.fromARGB(
                                                  255, 4, 62, 107)),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "S/.${producto.precio}0 ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: largoActual * 0.022,
                                                  color: const Color.fromARGB(
                                                      255, 4, 62, 107)),
                                            ),
                                            Text(
                                              producto.descripcion
                                                  .toUpperCase(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: largoActual * 0.017,
                                                  color: const Color.fromARGB(
                                                      255, 4, 62, 107)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  disminuir(index);
                                                });
                                              },
                                              iconSize: largoActual * 0.041,
                                              color: const Color.fromARGB(
                                                  255, 0, 57, 103),
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                color: Color.fromRGBO(
                                                    0, 170, 219, 1.000),
                                              ),
                                            ),
                                            Text(
                                              "${producto.cantidad}",
                                              style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 4, 62, 107),
                                                  fontSize: largoActual * 0.034,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  incrementar(index);
                                                });
                                              },
                                              iconSize: largoActual * 0.041,
                                              color: const Color.fromARGB(
                                                  255, 0, 49, 89),
                                              icon: const Icon(
                                                Icons.add_circle,
                                                color: Color.fromRGBO(
                                                    0, 170, 219, 1.000),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: anchoActual * 0.055),
                              child: Text(
                                "Subtotal:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: largoActual * 0.021,
                                    color:
                                        const Color.fromARGB(255, 1, 25, 44)),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: anchoActual * 0.055),
                              child: Text(
                                "S/.${total}0",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: largoActual * 0.027,
                                    color:
                                        const Color.fromARGB(255, 4, 62, 107)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(right: anchoActual * 0.055),
                              child: Text(
                                "Agregar al carrito",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: largoActual * 0.021,
                                    color:
                                        const Color.fromARGB(255, 1, 32, 56)),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(right: anchoActual * 0.055),
                              child: ElevatedButton(
                                  onPressed: almenosUno
                                      ? () {
                                          obtenerProductos();
                                          pedidoMio = PedidoModel(
                                            seleccionados: productosProvider,
                                            seleccionadosPromo: promosProvider,
                                            cantidadProd:
                                                productosProvider.length +
                                                    promosProvider.length,
                                            totalProds: totalProvider,
                                            envio: envio,
                                          );
                                          Provider.of<PedidoProvider>(context,
                                                  listen: false)
                                              .updatePedido(pedidoMio);
                                        }
                                      : null,
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(8),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color.fromRGBO(
                                                  120, 251, 99, 1.000))),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ))));
  }
}
