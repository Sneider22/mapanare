import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/game/snake_game.dart';

// Pruebas de la lógica: como SnakeGame no depende de Flutter, se puede
// probar sola, sin abrir ninguna pantalla.
void main() {
  test('arranca quieta y la primera tecla la pone a jugar', () {
    final g = SnakeGame(10);
    expect(g.status, GameStatus.ready);
    g.step();
    expect(g.snake.first, const Point(3, 5)); // no se movió

    g.turn(Direction.right);
    expect(g.status, GameStatus.playing);
    g.step();
    expect(g.snake.first, const Point(4, 5));
    expect(g.snake.length, 3); // pequeño = 3 casillas, y sin comer no crece
  });

  test('no se puede dar la vuelta en U', () {
    final g = SnakeGame(10)..turn(Direction.right);
    g.turn(Direction.left);
    g.step();
    expect(g.snake.first, const Point(4, 5)); // siguió a la derecha
  });

  test('dos giros rápidos se aplican uno por paso', () {
    final g = SnakeGame(10)..turn(Direction.right);
    g.turn(Direction.up);
    g.turn(Direction.left);
    g.step();
    expect(g.snake.first, const Point(3, 4)); // subió
    g.step();
    expect(g.snake.first, const Point(2, 4)); // y luego a la izquierda
  });

  test('chocar contra la pared termina la partida', () {
    final g = SnakeGame(10)..turn(Direction.right);
    for (var i = 0; i < 20; i++) {
      g.step();
    }
    expect(g.status, GameStatus.gameOver);
    expect(g.snake.first, const Point(9, 5)); // se quedó en el borde
  });

  test('el campo mediano arranca con 4 casillas', () {
    expect(SnakeGame(15).snake.length, 4);
  });

  test('comer hace crecer, suma punto y mueve la comida', () {
    final g = SnakeGame(10)..turn(Direction.right);
    g.food = const Point(4, 5); // justo enfrente de la cabeza
    g.step();
    expect(g.snake.length, 4); // creció 1
    expect(g.score, 1);
    expect(g.snake.contains(g.food), isFalse); // la nueva no cae encima
  });

  test('morderse a sí misma termina la partida', () {
    // Culebra larga: la hacemos comer 2 veces seguidas (5 casillas).
    final g = SnakeGame(10)..turn(Direction.right);
    g.food = const Point(4, 5);
    g.step();
    g.food = const Point(5, 5);
    g.step();
    g.food = const Point(0, 0); // lejos, para que no estorbe
    // Da la vuelta en un cuadrito: abajo, izquierda, arriba -> se muerde.
    g.turn(Direction.down);
    g.step();
    g.turn(Direction.left);
    g.step();
    g.turn(Direction.up);
    g.step();
    expect(g.status, GameStatus.gameOver);
  });
}
