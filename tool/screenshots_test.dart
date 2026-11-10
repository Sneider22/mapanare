// Genera las capturas del README en docs/screenshots/.
// Uso: flutter test tool/screenshots_test.dart

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/game/board_size.dart';
import 'package:mapanare/game/food.dart';
import 'package:mapanare/game/game_mode.dart';
import 'package:mapanare/game/snake_game.dart';
import 'package:mapanare/screens/game_screen.dart';
import 'package:mapanare/screens/home_screen.dart';
import 'package:mapanare/screens/how_to_screen.dart';

final _key = GlobalKey();

Future<void> _shot(
  WidgetTester t,
  Widget screen,
  Duration wait,
  String name,
) async {
  t.view.physicalSize = const Size(1080, 1920);
  t.view.devicePixelRatio = 3;
  await t.pumpWidget(
    RepaintBoundary(
      key: _key,
      child: MaterialApp(debugShowCheckedModeBanner: false, home: screen),
    ),
  );
  var left = wait;
  while (left > Duration.zero) {
    final d = left > const Duration(milliseconds: 100)
        ? const Duration(milliseconds: 100)
        : left;
    await t.pump(d);
    left -= d;
  }
  await t.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('docs/screenshots/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  await t.pumpWidget(const SizedBox());
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('PressStart2P')
      ..addFont(rootBundle.load('assets/fonts/PressStart2P-Regular.ttf'));
    await loader.load();
  });

  testWidgets('inicio', (t) async {
    await _shot(
      t,
      const HomeScreen(),
      const Duration(milliseconds: 2700),
      'inicio',
    );
  });

  testWidgets('juego', (t) async {
    final g = SnakeGame(15, criollo: true, random: Random(4));
    // Una culebra larga dando vueltas, con comida y un anís en el campo.
    g.snake = const [
      Point(9, 4),
      Point(8, 4),
      Point(7, 4),
      Point(6, 4),
      Point(5, 4),
      Point(4, 4),
      Point(3, 4),
      Point(3, 5),
      Point(3, 6),
      Point(3, 7),
      Point(4, 7),
      Point(5, 7),
      Point(6, 7),
      Point(7, 7),
      Point(8, 7),
      Point(9, 7),
      Point(10, 7),
      Point(11, 7),
      Point(11, 8),
      Point(11, 9),
    ];
    g.previous = g.snake;
    g.food = const Point(12, 3);
    g.anis = const Point(6, 11);
    g.anisLeft = 50;
    g.score = 16;
    g.status = GameStatus.playing;
    await _shot(
      t,
      GameScreen(
        size: BoardSize.mediano,
        food: Food.arepa,
        mode: GameMode.criollo,
        game: g,
      ),
      const Duration(milliseconds: 60),
      'juego',
    );
  });

  testWidgets('como-jugar', (t) async {
    await _shot(
      t,
      const HowToScreen(),
      const Duration(milliseconds: 15500),
      'como-jugar',
    );
  });
}
