import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/game/snake_game.dart';

// Pruebas de las sorpresas del modo Criollo.
void main() {
  test('el anís vale 3 puntos e invierte los controles un rato', () {
    final g = SnakeGame(15, criollo: true, random: Random(1))
      ..turn(Direction.right);
    g.anis = g.snake.first + const Point(1, 0); // justo enfrente
    g.anisLeft = 10;
    g.step();
    expect(g.score, SnakeGame.anisPoints);
    expect(g.anis, isNull);
    expect(g.inverted, isTrue);

    // Al revés: apretar ↑ hace que baje.
    g.turn(Direction.up);
    final y = g.snake.first.y;
    g.step();
    expect(g.snake.first.y, y + 1);
    expect(g.invertedLeft, SnakeGame.invertedDuration - 1); // va bajando
  });

  test('el anís desaparece si no te lo comes a tiempo', () {
    final g = SnakeGame(20, criollo: true)..turn(Direction.right);
    g.anis = const Point(0, 0);
    g.anisLeft = 3;
    for (var i = 0; i < 3; i++) {
      g.step();
    }
    expect(g.anis, isNull);
  });

  test('el apagón avisa parpadeando, se va la luz y vuelve', () {
    final g = SnakeGame(20, criollo: true, random: Random(2));
    // Vamos en círculos para no chocar nunca.
    const loop = [
      Direction.right,
      Direction.down,
      Direction.left,
      Direction.up,
    ];
    var sawFlicker = false, sawDark = false, sawLightBack = false;
    g.turn(Direction.right);
    for (var i = 0; i < 400 && !g.isOver; i++) {
      if (i % 3 == 0) g.turn(loop[(i ~/ 3) % 4]);
      g.food = const Point(19, 19); // que no estorbe la comida
      g.step();
      if (g.flickering) sawFlicker = true;
      if (g.dark) {
        expect(sawFlicker, isTrue); // siempre avisa antes
        sawDark = true;
      }
      if (sawDark && !g.dark) sawLightBack = true;
    }
    expect(g.isOver, isFalse);
    expect([sawFlicker, sawDark, sawLightBack], [true, true, true]);
  });

  test('el modo clásico no tiene sorpresas', () {
    final g = SnakeGame(20, random: Random(3))..turn(Direction.right);
    const loop = [
      Direction.right,
      Direction.down,
      Direction.left,
      Direction.up,
    ];
    for (var i = 0; i < 400; i++) {
      if (i % 3 == 0) g.turn(loop[(i ~/ 3) % 4]);
      g.step();
      expect(g.anis, isNull);
      expect(g.flickering || g.dark, isFalse);
    }
  });
}
