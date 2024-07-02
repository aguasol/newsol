import 'dart:io';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class Pdf extends StatefulWidget {
  final int? rutaID;
  final int? pedidos;
  final int? pedidosEntregados;
  final int? pedidosTruncados;
  final double? totalMonto;
  final double? totalYape;
  final double? totalPlin;
  final double? totalEfectivo;
  final List<int>? idpedidos;
  const Pdf(
      {Key? key,
      this.rutaID,
      this.pedidos,
      this.pedidosEntregados,
      this.pedidosTruncados,
      this.totalMonto,
      this.totalYape,
      this.totalPlin,
      this.totalEfectivo,
      this.idpedidos})
      : super(key: key);

  @override
  State<Pdf> createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  String pathh = "";
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);

  Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

  Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/$name');
    //print("----${dir.path}");

    await file.writeAsBytes(bytes);

    return file;
  }

  List<pw.TableRow> _generateTableRows(List<Uint8List> fotos) {
    List<pw.TableRow> rows = [
      pw.TableRow(children: [
        pw.Text("Ruta",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Pedido ID",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Cliente",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Descuento",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Foto",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ]),
    ];

    for (int idPedido in widget.idpedidos ?? []) {
      rows.add(pw.TableRow(children: [
        pw.Text("data 1"),
        pw.Text("$idPedido"),
        pw.Text("data 2"),
        pw.Text("data 3"),
        pw.Container(
          height: 100,
          width: 50,
          child: pw.Image(
              pw.MemoryImage(fotos[widget.idpedidos!.indexOf(idPedido)])),
        ),
      ]));
    }

    return rows;
  }

  Future<File> _createPDF(String text) async {
    // imagenes
    final ByteData logoEmpresa =
        await rootBundle.load('lib/imagenes/logo_sol_tiny.png');
    Uint8List logoData = (logoEmpresa).buffer.asUint8List();
    List<Uint8List> fotos = [];
    //print("-----------------------------------------------");
    //print(widget.idpedidos);
    for (var pedido in widget.idpedidos!) {
      final pass = await getApplicationDocumentsDirectory();
      final otro = path.join(pass.path, 'pictures/$pedido.jpg');
      if (File(otro).existsSync()) {
        List<int> bytes = await File(otro).readAsBytes();
        ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
        Uint8List finalByte = (byteData).buffer.asUint8List();
        fotos.add(finalByte);
      } else {
        //print("El archivo no existe.");
        fotos.add(logoData);
      }
    }
    //print(".......dentro d create");
    final pdf = pw.Document();

    // SECCION 1
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
        build: (context) => [
          // Titulos
          pw.Center(
            child: pw.Text("Informe de ventas",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                )),
          ),

          // FECHA
          pw.Center(
            child: pw.Text(
                "Del: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                )),
          ),

          // DATOS PERSONALES
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                    //color: PdfColor.fromHex('#4B366A'),
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(20)),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Nombres: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Apellidos: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Dni: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Cargo: Conductor",
                              style: const pw.TextStyle(fontSize: 20))
                        ])),
                pw.Container(
                    height: 100,
                    width: 100,
                    child: pw.Image(pw.MemoryImage(logoData)))
              ]),
          pw.SizedBox(height: 5),
          pw.Container(
              child: pw.Text("RESUMEN".toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold))),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("Ruta asignada: ${widget.rutaID}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos por entregar: ${widget.pedidos}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos entregados: ${widget.pedidosEntregados}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos truncados: ${widget.pedidosTruncados}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# cantidad recaudada: ${widget.totalMonto}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por yape: ${widget.totalYape}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por efectivo: ${widget.totalEfectivo}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por plin: ${widget.totalPlin}",
                style: const pw.TextStyle(fontSize: 20))
          ]),
          // TITULO
          pw.Container(
              child: pw.Text(
                  "1.- Detalle de pedidos entregados y pendientes"
                      .toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold))),

          pw.SizedBox(
            height: 10,
          ),

          // INFORME
          pw.Container(
              child: pw.Table(
                  border: pw.TableBorder.all(),
                  children: _generateTableRows(fotos))),
        ],
      ),
    );

    return saveDocument(
        name:
            'informe_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
        pdf: pdf);
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
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
            Color.fromRGBO(0, 106, 252, 1.000),
            Color.fromRGBO(0, 106, 252, 1.000),
            Colors.white,
            Colors.white,
          ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Container()),
                    Text(
                      '¡Felicidades,\n${userProvider.user?.nombre}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: largoActual * 0.04),
                    ),
                    Text(
                      'Ya puedes regresar al almacen para cuadrar tus ventas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: largoActual * 0.025),
                    ),
                    Stack(children: [
                      Positioned(
                        left: anchoActual * 0.15,
                        height: largoActual * 0.4,
                        child: Lottie.asset('lib/imagenes/anim_1.json'),
                      ),
                      SizedBox(
                        height: largoActual * 0.35,
                        child: Lottie.asset('lib/imagenes/anim_23.json'),
                      ),
                      Positioned(
                        left: anchoActual * 0.11,
                        height: largoActual * 0.35,
                        child: Lottie.asset('lib/imagenes/brazo.json'),
                      ),
                    ]),
                    SizedBox(
                      height: largoActual * 0.05,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pdfFile = await _createPDF('Sample Text');
                        openFile(pdfFile);
                        SharedPreferences actualizadoStock =
                            await SharedPreferences.getInstance();
                        actualizadoStock.setBool("actualizado", false);
                        SharedPreferences rutaFinalizada =
                            await SharedPreferences.getInstance();
                        rutaFinalizada.setBool("finalizado", true);
                        SharedPreferences fechaFinalizado =
                            await SharedPreferences.getInstance();
                        fechaFinalizado.setString(
                            "fecha", DateTime.now().toString());
                        SharedPreferences click =
                            await SharedPreferences.getInstance();
                        click.setBool('descarga', true);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(colorBotonesAzul),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .download_rounded, // Reemplaza con el icono que desees
                            size: largoActual * 0.028,
                            color: Colors.white,
                          ),
                          SizedBox(
                              width: anchoActual *
                                  0.01), // Ajusta el espacio entre el icono y el texto según tus preferencias
                          Text(
                            " Descargar",
                            style: TextStyle(
                                fontSize: largoActual * 0.025,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HolaConductor()));
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(colorBotonesAzul),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home, // Reemplaza con el icono que desees
                            size: largoActual * 0.028,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: largoActual * 0.17,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
