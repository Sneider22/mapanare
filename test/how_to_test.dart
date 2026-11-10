import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/screens/how_to_screen.dart';

void main() {
  testWidgets('el video de Cómo jugar avanza y el texto se escribe',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HowToScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    // Al principio casi no hay texto...
    expect(find.textContaining('La culebra siempre avanza'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    // ...y a los 2 segundos ya se escribió el comienzo.
    expect(find.textContaining('La culebra siempre avanza'), findsOneWidget);
  });
}
