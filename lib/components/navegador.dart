import 'package:flutter/material.dart';
import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/perfilcliente.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/components/estado_pedido.dart';
import 'package:appsol_final/components/productos.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';

class BarraNavegacion extends StatefulWidget {
  final int indice;
  final int subIndice;
  const BarraNavegacion(
      {required this.indice, required this.subIndice, Key? key})
      : super(key: key);

  @override
  State<BarraNavegacion> createState() => _BarraNavegacion();
}

class _BarraNavegacion extends State<BarraNavegacion> {
  int indexSelecionado = 0;
  int clienteID = 0;
  final screensMiPerfil = [
    const PerfilCliente(),
  ];

  //TODO ESTO ES MIOOIOOO
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    int subIndex = widget.subIndice;
    final screensHola = [
      Hola2(
        clienteId: userProvider.user?.id,
        esNuevo: userProvider.user?.esNuevo,
      ),
      const Promos(),
      const Productos(),
      const Pedido(),
    ];
    final screensMisPedidos = [
      EstadoPedido(
        clienteId: userProvider.user?.id,
      ),
    ];
    final screens = [screensHola, screensMiPerfil, screensMisPedidos];
    final items = <Widget>[
      const Icon(
        Icons.home_rounded,
        color: Colors.white,
      ),
      const Icon(Icons.person, color: Colors.white),
      const Icon(Icons.assignment_rounded, color: Colors.white),
    ];
    /*print('------  INICIALIZADOOO ------------');
    print('------  INDICEEEE');
    print(indexSelecionado);
    print('------SUBINDICE');
    print(subIndex);*/

    //ESTAS TRES LINEASSSS SON DE LUIS >:p
    if (subIndex > screens[indexSelecionado].length - 1) {
      //print('es mayor');
      subIndex = 0;
    }
    //SOLO UNA IDEA NADA DE CODIGO
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        body: screens[indexSelecionado][subIndex],
        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          color: const Color.fromRGBO(0, 106, 252, 1.000),
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              subIndex = 0;
              indexSelecionado = index;
              /*print('------  onTAPP ------------');
              print('------  INDICEEEE');
              print(indexSelecionado);
              print('------SUBINDICE');
              print(subIndex);*/
            });
          },
          index: indexSelecionado,
          items: items,
        ),
      ),
    );
  }
}
