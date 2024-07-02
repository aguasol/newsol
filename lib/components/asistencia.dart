import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class Asistencia extends StatefulWidget {
  const Asistencia({super.key});

  @override
  State<Asistencia> createState() => _AsistenciaState();
}

class _AsistenciaState extends State<Asistencia> {
  @override
  Widget build(BuildContext context) {
    //final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text("Ancho X largo: ${anchoActual}x ${largoActual.toStringAsFixed(2)}"),
                      Container(
                        child: Text(
                          "Estamos aquí",
                          style: TextStyle(
                              fontSize: largoActual * 0.04,
                              color: const Color.fromARGB(255, 2, 73, 132)),
                        ),
                      ),
                      Container(
                        child: Text(
                          "para ayudarte",
                          style: TextStyle(fontSize: largoActual * 0.04),
                        ),
                      ),

                      Container(
                        child: Text(
                          "Llámanos a este número ",
                          style: TextStyle(fontSize: largoActual * 0.04),
                        ),
                      ),
                      Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                                onPressed: () async {
                                  final Uri url = Uri(
                                    scheme: 'tel',
                                    path: '955372038',
                                  ); // Acciones al hacer clic en el FloatingActionButton
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                   // print('no se puede llamar');
                                  }
                                },
                                child: Text(
                                  "955372038",
                                  style: TextStyle(
                                      fontSize: largoActual * 0.04,
                                      color: Color.fromARGB(255, 6, 57, 100)),
                                )).animate().fade(delay: 000.ms).shake(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 40),
                            height: largoActual * 0.1,
                            child: Lottie.asset('lib/imagenes/callcenter.json'),
                          )
                        ],
                      )),
                    ]))));
  }
}
