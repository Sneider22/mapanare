import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/game/board_size.dart';
import 'package:mapanare/game/game_mode.dart';
import 'package:mapanare/game/records.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('los récords se guardan y sobreviven a "cerrar la app"', () async {
    SharedPreferences.setMockInitialValues({}); // cuadernito falso, vacío
    await Records.load();

    expect(Records.submit(GameMode.criollo, BoardSize.grande, 12), isTrue);
    expect(Records.submit(GameMode.criollo, BoardSize.grande, 5), isFalse);

    await Records.load(); // como abrir la app de nuevo
    expect(Records.best(GameMode.criollo, BoardSize.grande), 12);
    expect(Records.best(GameMode.clasico, BoardSize.grande), 0);
    expect(Records.top, 12);

    await Records.clear();
    await Records.load();
    expect(Records.top, 0);
  });
}
