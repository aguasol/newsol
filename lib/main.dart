/*import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/permiso.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
// Importa el paquete permission_handler

late List<CameraDescription> camera;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences userDataCopy = await SharedPreferences.getInstance();
  String? token = userDataCopy.getString('token');
  bool estalogeado = token != null;
  await dotenv.load(fileName: ".env");
  //camera = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  UserProvider userProvider = UserProvider();
  await userProvider.initUser();
  runApp(MyApp(estalogeado: estalogeado));
}

class MyApp extends StatelessWidget {
  final bool estalogeado;
  const MyApp({Key? key, required this.estalogeado}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PedidoProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UbicacionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UbicacionListProvider(),
        ),
      ],
      child: MaterialApp(
        //title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: estalogeado
            ? BarraNavegacion(
                indice: 0,
                subIndice: 0,
              )
            : Login(),
        /*home: BarraNavegacion(
          indice: 0,
          subIndice: 0,
        ),*/
      ),
    );
  }
}*/
import 'dart:convert';

import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:appsol_final/components/holaconductor.dart';

late List<CameraDescription> camera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  print("userJson main ---------------------------------");
  print(userJson);
  bool estalogeado = userJson != null; //false = nologeado, true = logeado
  print("estalogeado------------------------");
  print(estalogeado);
  var prueba = UserModel();
  print(prueba.rolid);
  //prefs.remove('user');
  int rol = 0;
  if (estalogeado == true) {
    rol = jsonDecode(userJson!)['rolid'];
  }
  print(rol);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializamos el UserProvider y cargamos el usuario
  UserProvider userProvider = UserProvider();
  await userProvider.initUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => PedidoProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionListProvider()),
        ChangeNotifierProvider(create: (context) => RutaProvider()),
      ],
      child: MyApp(estalogeado: estalogeado, rol: rol),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool estalogeado;
  final int rol;
  const MyApp({Key? key, required this.estalogeado, required this.rol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      //home: estalogeado && rol == 4 ? BarraNavegacion(indice: 0,subIndice: 0,) : (estalogeado && rol == 5 ? HolaConductor() :Login()),
      home: estalogeado
          ? (rol == 4
              ? BarraNavegacion(
                  indice: 0,
                  subIndice: 0,
                )
              : (rol == 5 ? HolaConductor() : Login()))
          : Login(),
    );
  }
}
