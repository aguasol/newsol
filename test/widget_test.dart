import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:appsol_final/main.dart';

void main() {
  const bool.fromEnvironment('FLUTTER_TEST', defaultValue: true);

  setUpAll(() async {
    // Inicializa Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();
    
    // Carga las variables de entorno
    await dotenv.load(fileName: ".env");

    // Limpia las preferencias compartidas para las pruebas
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(estalogeado: false, rol: 0));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
