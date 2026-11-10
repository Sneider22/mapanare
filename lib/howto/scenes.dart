import 'dart:math';

import '../game/food.dart';
import '../game/snake_game.dart';
import '../widgets/pixel_board.dart';
import '../widgets/pixel_foods.dart';

// LOS "VIDEOS" DE CÓMO JUGAR.
// Cada video se arma como un guion: `chapter(...)` abre un capítulo con
// su explicación y `play('RRUU')` mueve la culebra (R = derecha,
// L = izquierda, U = arriba, D = abajo). Aquí se simula paso a paso,
// igual que el juego, y salen los cuadros de la animación.
// Para cambiar un video, cambia las letras o los textos de abajo.

const sceneCols = 12;
const sceneRows = 7;
const typeMs = 20; // cuánto tarda en escribirse cada letra
const _readMs = 2400; // tiempo extra para leer cuando termina de escribirse

// Un cuadro del video.
class SceneFrame {
  const SceneFrame(
    this.view, {
    required this.chapter,
    this.pressed,
    this.score = 0,
    this.banner,
  });

  final BoardView view;
  final int chapter; // en qué capítulo va
  final Direction? pressed; // la flecha que "aprieta" el jugador
  final int score;
  final String? banner; // letrero corto debajo del tablero
}

class Chapter {
  const Chapter(this.title, this.text, this.startFrame, this.endFrame);

  final String title;
  final String text;
  final int startFrame;
  final int endFrame; // (no incluido)

  int get length => endFrame - startFrame;
}

class HowToScene {
  const HowToScene({
    required this.title,
    required this.chapters,
    required this.frames,
    required this.stepMs,
    this.showKeys = false,
  });

  final String title;
  final List<Chapter> chapters;
  final List<SceneFrame> frames;
  final int stepMs; // cuánto dura cada cuadro
  final bool showKeys; // mostrar las flechas debajo
}

Direction _dir(String c) => switch (c) {
  'U' => Direction.up,
  'D' => Direction.down,
  'L' => Direction.left,
  _ => Direction.right,
};

// El "director" del video: va guardando cuadros mientras le dices qué
// pasa. `flicker`, `dark` y `anis` se pueden cambiar entre jugadas.
class _Video {
  _Video({
    required this.stepMs,
    required List<Point<int>> start,
    this.foods = const [],
  }) : _snake = List.of(start) {
    _food = _nextFood();
  }

  final int stepMs;
  final List<Point<int>> foods;
  List<Point<int>> _snake;
  int _foodIndex = 0;
  Point<int>? _food;
  Point<int>? anis;
  bool flicker = false; // las luces parpadean
  bool dark = false; // apagón
  int _invertedLeft = 0;
  bool _crashed = false;
  int _score = 0;

  final _frames = <SceneFrame>[];
  final _titles = <String>[];
  final _texts = <String>[];
  final _starts = <int>[];

  Point<int>? _nextFood() =>
      _foodIndex < foods.length ? foods[_foodIndex++] : null;

  void chapter(String title, String text) {
    _fillChapter();
    _titles.add(title);
    _texts.add(text);
    _starts.add(_frames.length);
  }

  // Si el capítulo es muy corto para leer su texto, el video espera.
  void _fillChapter() {
    if (_starts.isEmpty) return;
    final needed = ((_texts.last.length * typeMs + _readMs) / stepMs).ceil();
    while (_frames.length - _starts.last < needed) {
      wait();
    }
  }

  void wait([int n = 1]) {
    for (var i = 0; i < n; i++) {
      _emit();
    }
  }

  void play(String moves) {
    for (final c in moves.split('')) {
      if (_crashed) return;
      final d = _dir(c);
      final head = _snake.first + d.vector;
      final eats = head == _food || head == anis;
      final body = eats ? _snake : _snake.sublist(0, _snake.length - 1);
      final out =
          head.x < 0 ||
          head.y < 0 ||
          head.x >= sceneCols ||
          head.y >= sceneRows;
      if (out || body.contains(head)) {
        _crashed = true; // de aquí en adelante la cabeza parpadea en rojo
        _emit();
        return;
      }
      if (_invertedLeft > 0) _invertedLeft--;
      if (eats) {
        _snake = [head, ..._snake];
        if (head == anis) {
          _score += SnakeGame.anisPoints;
          anis = null;
          _invertedLeft = 14;
        } else {
          _score++;
          _food = _nextFood();
        }
      } else {
        _snake = [head, ..._snake.sublist(0, _snake.length - 1)];
      }
      // Con los controles al revés, la flecha que aprietas es la contraria.
      _emit(_invertedLeft > 0 ? d.opposite : d);
    }
  }

  void _emit([Direction? pressed]) {
    final n = _frames.length;
    final inverted = _invertedLeft > 0;
    final banner = _crashed
        ? 'CHOCASTE'
        : flicker
        ? 'LA LUZ ESTÁ FALLANDO...'
        : dark
        ? 'SE FUE LA LUZ'
        : inverted
        ? 'CONTROLES AL REVÉS'
        : anis != null
        ? '¡APARECIÓ UN ANÍS! +3'
        : null;
    _frames.add(
      SceneFrame(
        BoardView(
          cols: sceneCols,
          rows: sceneRows,
          snake: _snake,
          food: _food,
          foodSprite: foodSprites[Food.arepa],
          anis: anis,
          crashed: _crashed && n.isEven,
          inverted: inverted,
          dark: !_crashed && (dark || (flicker && n.isOdd)),
        ),
        chapter: _titles.length - 1,
        pressed: pressed,
        score: _score,
        banner: banner,
      ),
    );
  }

  HowToScene build(String title, {bool showKeys = false}) {
    _fillChapter();
    wait(4); // pausita antes de repetir el video
    final chapters = [
      for (var i = 0; i < _titles.length; i++)
        Chapter(
          _titles[i],
          _texts[i],
          _starts[i],
          i + 1 < _starts.length ? _starts[i + 1] : _frames.length,
        ),
    ];
    return HowToScene(
      title: title,
      chapters: chapters,
      frames: _frames,
      stepMs: stepMs,
      showKeys: showKeys,
    );
  }
}

// Culebra en línea recta mirando a la derecha, con la cabeza en (x, y).
List<Point<int>> _line(int x, int y, int length) => [
  for (var i = 0; i < length; i++) Point(x - i, y),
];

// ===== VIDEO 1: LO BÁSICO =====
HowToScene _basics() {
  final v = _Video(
    stepMs: 200,
    start: _line(3, 3, 3),
    foods: const [
      Point(10, 1), Point(10, 5), Point(6, 5), Point(1, 5), //
      Point(6, 0), Point(4, 1), Point(9, 2), Point(5, 4),
    ],
  );
  v.chapter(
    'MUÉVETE',
    'La culebra siempre avanza sola. Tú decides hacia dónde gira: usa '
        'las flechas o W A S D. En el teléfono, desliza el dedo hacia '
        'donde quieres ir.',
  );
  v.wait(3);
  v.play('RRUURRDDDDLLLLUU');

  v.chapter(
    'COME Y CRECE',
    'Cada comida suma 1 punto y te hace un cuadro más larga. Apenas te '
        'comes una, aparece otra en un lugar al azar del campo.',
  );
  v.play('UURRRRRRRDDDDLLLLLLLLL');

  v.chapter(
    'ORGANÍZATE',
    'Mientras más larga, menos espacio libre. Un buen truco es recorrer '
        'el campo en filas, de lado a lado: así tu cuerpo queda ordenado '
        'y siempre tienes una salida.',
  );
  v.play('LUUUUURRRRRRRRRRRDLLLLLLLLLLDRRRRRRRRR');

  v.chapter(
    'NO CHOQUES',
    'La partida termina si tocas una pared o tu propio cuerpo. Tampoco '
        'puedes devolverte de golpe: para ir en sentido contrario tienes '
        'que girar dos veces.',
  );
  v.play('DLU'); // se muerde
  return v.build('LO BÁSICO', showKeys: true);
}

// ===== VIDEO 2: EL ANÍS =====
HowToScene _anis() {
  final v = _Video(
    stepMs: 200,
    start: _line(3, 5, 4),
    foods: const [Point(10, 1), Point(4, 1), Point(9, 5)],
  );
  v.anis = const Point(8, 3);
  v.chapter(
    'UNA BOTELLA DE ANÍS',
    'En el modo Criollo, a veces aparece una botella de anís. Vale 3 '
        'puntos, pero dura poco en el campo: cuando empieza a parpadear, '
        'está por desaparecer.',
  );
  v.wait(3);
  v.play('RRRUU');

  v.chapter(
    'CONTROLES AL REVÉS',
    'Si te la tomas, por 5 segundos los controles se invierten: arriba '
        'es abajo e izquierda es derecha. La culebra se pone morada para '
        'que no lo olvides.',
  );
  v.play('RRRUURRDDDDLLLL');

  v.chapter(
    '¿VALE LA PENA?',
    'Tómala solo si tienes espacio libre alrededor. Si estás larga y '
        'encerrada, mejor déjala pasar: 3 puntos no valen una partida.',
  );
  v.play('UUULLLU');
  return v.build('EL ANÍS · MODO CRIOLLO', showKeys: true);
}

// ===== VIDEO 3: EL APAGÓN =====
HowToScene _blackout() {
  final v = _Video(
    stepMs: 200,
    start: _line(3, 5, 4),
    foods: const [Point(8, 1), Point(2, 2), Point(9, 5)],
  );
  v.chapter(
    'LA LUZ ESTÁ FALLANDO',
    'En el modo Criollo, cada cierto tiempo hay un apagón. Primero las '
        'luces parpadean un momento: aprovecha para fijarte dónde está '
        'la comida.',
  );
  v.wait(3);
  v.play('RR');
  v.flicker = true;
  v.play('RRRUU');

  v.chapter(
    'SE FUE LA LUZ',
    'Durante unos segundos solo verás las casillas cerca de la cabeza. '
        'Muévete con calma hacia donde recuerdas que estaba la comida.',
  );
  v.flicker = false;
  v.dark = true;
  v.play('UULDLLLLL');

  v.chapter(
    'VOLVIÓ LA LUZ',
    'Después la luz vuelve sola y todo sigue normal. Durante el apagón, '
        'aléjate de las paredes y no te metas entre tu propio cuerpo.',
  );
  v.dark = false;
  v.play('DDDRRRRRRR');
  return v.build('EL APAGÓN · MODO CRIOLLO');
}

final howToScenes = <HowToScene>[_basics(), _anis(), _blackout()];
