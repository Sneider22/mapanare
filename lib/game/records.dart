import 'package:shared_preferences/shared_preferences.dart';

import 'board_size.dart';
import 'game_mode.dart';

// EL CUADERNITO DE RÉCORDS.
// Guarda el mejor puntaje de cada combinación modo + campo (2 × 3 = 6)
// en el propio dispositivo con shared_preferences. En la web eso queda en
// el navegador (localStorage), así que sobrevive aunque cierres la app.
//
// Truco: al arrancar la app leemos todo UNA vez y lo dejamos en memoria
// (`_cache`). Así el resto del juego lo consulta al instante, sin esperas.
class Records {
  Records._(); // nadie crea objetos Records: todo es `static`

  static SharedPreferences? _prefs;
  static final Map<String, int> _cache = {};

  // Cada récord se guarda con un nombre único, ej: "record_criollo_grande".
  static String _key(GameMode mode, BoardSize size) =>
      'record_${mode.name}_${size.name}';

  // Se llama una sola vez en main(), antes de mostrar la app.
  static Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      for (final m in GameMode.values) {
        for (final s in BoardSize.values) {
          final k = _key(m, s);
          _cache[k] = _prefs!.getInt(k) ?? 0;
        }
      }
    } catch (_) {
      // Si el navegador bloquea el guardado (ej. modo incógnito estricto),
      // el juego sigue funcionando: los récords solo duran la sesión.
      _prefs = null;
    }
  }

  static int best(GameMode mode, BoardSize size) =>
      _cache[_key(mode, size)] ?? 0;

  // El mejor de todos, para mostrarlo en grande.
  static int get top => _cache.values.fold(0, (a, b) => a > b ? a : b);

  // Al terminar una partida. Devuelve true si fue récord nuevo.
  static bool submit(GameMode mode, BoardSize size, int score) {
    if (score <= best(mode, size)) return false;
    final k = _key(mode, size);
    _cache[k] = score;
    _prefs?.setInt(k, score); // se escribe en segundo plano
    return true;
  }

  // Para el botón BORRAR de la pantalla de récords.
  static Future<void> clear() async {
    for (final k in _cache.keys) {
      _cache[k] = 0;
      await _prefs?.remove(k);
    }
  }
}
