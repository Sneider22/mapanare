import 'dart:math';

import 'package:flutter/material.dart';

import '../game/food.dart';
import 'food_painter.dart';
import 'snake_colors.dart';

// CustomPainter = dibujar "a mano" sobre un lienzo (Canvas), como en un
// juego. Flutter llama a paint() cada vez que hay que redibujar.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.cells,
    required this.snake,
    required this.previous,
    required this.progress,
    required this.food,
    required this.foodPos,
  });

  final int cells; // casillas por lado
  final List<Point<int>> snake; // snake[0] es la cabeza
  final List<Point<int>> previous; // dónde estaba en el paso anterior
  final double progress; // 0 = en `previous`, 1 = en `snake`
  final Food food; // qué comida dibujar
  final Point<int> foodPos; // en qué casilla está

  static const _grassLight = Color(0xFF7DB847);
  static const _grassDark = Color(0xFF6EA83C);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / cells; // tamaño de cada casilla en píxeles

    _paintGrass(canvas, cell);
    drawFood(canvas, food, _center(foodPos, cell), cell);
    _paintSnake(canvas, cell);
  }

  // Centro en píxeles de una casilla.
  Offset _center(Point<int> p, double cell) =>
      Offset((p.x + 0.5) * cell, (p.y + 0.5) * cell);

  // Patrón de cuadritos tipo tablero de ajedrez con dos verdes.
  void _paintGrass(Canvas canvas, double cell) {
    final light = Paint()..color = _grassLight;
    final dark = Paint()..color = _grassDark;
    for (var x = 0; x < cells; x++) {
      for (var y = 0; y < cells; y++) {
        final rect = Rect.fromLTWH(x * cell, y * cell, cell, cell);
        canvas.drawRect(rect, (x + y).isEven ? light : dark);
      }
    }
  }

  void _paintSnake(Canvas canvas, double cell) {
    // La "cuerda": una línea que pasa por el centro de cada casilla, de la
    // cola a la cabeza. Con trazo grueso y puntas/esquinas redondas se ve
    // como un solo cuerpo continuo en vez de cuadritos.
    //
    // MOVIMIENTO SUAVE: en vez de saltar de casilla en casilla, dibujamos la
    // culebra "a medio camino" entre el paso anterior y el actual.
    // Solo la punta de la cola y la cabeza se deslizan (con Offset.lerp,
    // que da el punto intermedio entre dos puntos según `progress`);
    // las casillas del medio son las mismas en los dos pasos.
    Offset slide(Point<int> from, Point<int> to) =>
        Offset.lerp(_center(from, cell), _center(to, cell), progress)!;

    final tail = slide(previous.last, snake.last);
    final head = slide(previous.first, snake.first);

    final body = Path()..moveTo(tail.dx, tail.dy);
    for (var i = snake.length - 1; i >= 1; i--) {
      final p = _center(snake[i], cell);
      body.lineTo(p.dx, p.dy);
    }
    body.lineTo(head.dx, head.dy);

    Paint rope(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final shadowShift = Offset(0, cell * 0.08);

    // 1) Sombra suave sobre la grama: el mismo cuerpo, corrido un poquito
    //    hacia abajo y negro transparente.
    final shadow = Colors.black.withValues(alpha: 0.18);
    canvas.drawPath(body.shift(shadowShift), rope(shadow, cell * 0.74));
    canvas.drawCircle(head + shadowShift, cell * 0.43, Paint()..color = shadow);

    // 2) Cuerpo: el tono del borde, y encima uno más claro y más finito.
    canvas.drawPath(body, rope(snakeEdge, cell * 0.72));
    canvas.drawPath(body, rope(snakeCenter, cell * 0.46));

    // 3) Cabeza: un poquito más ancha que el cuerpo, con los mismos 2 tonos.
    canvas.drawCircle(head, cell * 0.43, Paint()..color = snakeEdge);
    canvas.drawCircle(head, cell * 0.31, Paint()..color = snakeCenter);

    if (snake.length > 1) _paintEyes(canvas, cell, head);
  }

  // Los ojos miran hacia donde va la cabeza (cabeza - cuello).
  // `c` es el centro de la cabeza ya deslizada.
  void _paintEyes(Canvas canvas, double cell, Offset c) {
    final dx = (snake[0].x - snake[1].x).toDouble();
    final dy = (snake[0].y - snake[1].y).toDouble();

    final forward = Offset(dx, dy) * (cell * 0.12);
    final side = Offset(-dy, dx) * (cell * 0.19); // perpendicular
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = snakePupil;
    for (final eye in [c + forward + side, c + forward - side]) {
      canvas.drawCircle(eye, cell * 0.12, white);
      // La pupila un poco hacia adelante: parece que mira a donde va.
      final p = eye + forward * 0.35;
      canvas.drawCircle(p, cell * 0.065, pupil);
      // Brillito blanco en la pupila: le da vida al ojo.
      canvas.drawCircle(
          p + Offset(-cell * 0.02, -cell * 0.02), cell * 0.02, white);
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
