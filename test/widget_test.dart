import 'package:flutter_test/flutter_test.dart';

import 'package:mapanare/main.dart';

void main() {
  testWidgets('El menú muestra el título y el botón de jugar', (tester) async {
    await tester.pumpWidget(const MapanareApp());

    expect(find.text('MAPANARE'), findsOneWidget);
    expect(find.text('JUGAR'), findsOneWidget);
  });
}
