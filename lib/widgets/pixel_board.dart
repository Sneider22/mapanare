import 'dart:math';

import 'package:flutter/material.dart';

import '../arcade/arcade_style.dart';
import 'pixel_foods.dart';
import 'pixel_sprite.dart';
import 'snake_colors.dart';

// TODO LO QUE SE VE EN UN TABLERO, en un solo paquetico.
// Lo usan el juego de verdad y las escenitas de "Cómo jugar", así los dos
// se ven exactamente igual.
class BoardView {
  const BoardView({
    required this.cols,
    required this.rows,
    required this.snake,
    this.food,
    this.foodSprite,
    this.anis,
    this.crashed = false,
    this.inverted = false,
    this.dark = false,
  });

  final int cols;
  final int rows;
  final List<Point<int>> snake; // snake[0] = cabeza
  final Point<int>? food;
  final Sprite? foodSprite;
  final Point<int>? anis; // la botella, si hay una en el campo
  final bool crashed; // la cabeza se pinta roja
  final bool inverted; // controles al revés: la culebra cambia de color
  final bool dark; // apagón: solo se ve cerca de la cabeza
}

// Colores de la culebra cuando tiene los controles invertidos.
const _invertedEdge = Color(0xFF8E5BB5);
const _invertedCenter = invertedPurple;
const _crashColor = Color(0xFFFF3B5C);

class PixelBoardPainter extends CustomPainter {
  PixelBoardPainter(this.v);

  final BoardView v;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = min(size.width / v.cols, size.height / v.rows);
    Rect at(Point<int> p) => Rect.fromLTWH(p.x * cell, p.y * cell, cell, cell);

    // Fondo: campo verde oscuro a cuadros (igual que el demo del Inicio).
    final dark = Paint()..color = const Color(0xFF12301B);
    final light = Paint()..color = const Color(0xFF163A21);
    for (var x = 0; x < v.cols; x++) {
      for (var y = 0; y < v.rows; y++) {
        canvas.drawRect(at(Point(x, y)), (x + y).isEven ? dark : light);
      }
    }

    if (v.food != null && v.foodSprite != null) {
      v.foodSprite!.paintIn(canvas, at(v.food!).deflate(cell * 0.06));
    }
    if (v.anis != null) {
      anisSprite.paintIn(canvas, at(v.anis!).deflate(cell * 0.04));
    }

    _paintSnake(canvas, cell, at);

    // APAGÓN: tapamos de negro todo lo que esté lejos de la cabeza.
    // Se hace por casillas (no con un círculo suave) para que se vea pixel.
    if (v.dark && v.snake.isNotEmpty) {
      final h = v.snake.first;
      final shade = Paint();
      for (var x = 0; x < v.cols; x++) {
        for (var y = 0; y < v.rows; y++) {
          final d = sqrt(pow(x - h.x, 2) + pow(y - h.y, 2));
          if (d <= 1.5) continue; // las casillas pegadas se ven completas
          shade.color = Colors.black.withValues(alpha: d <= 2.5 ? 0.55 : 0.94);
          canvas.drawRect(at(Point(x, y)), shade);
        }
      }
    }
  }

  void _paintSnake(Canvas canvas, double cell, Rect Function(Point<int>) at) {
    final s = v.snake;
    if (s.isEmpty) return;
    final edge = Paint()..color = v.inverted ? _invertedEdge : snakeEdge;
    final center = Paint()..color = v.inverted ? _invertedCenter : snakeCenter;

    // De la cola a la cabeza, para que la cabeza quede encima.
    for (var i = s.length - 1; i >= 0; i--) {
      final r = at(s[i]);
      if (i == 0 && v.crashed) {
        canvas.drawRect(r.deflate(1), Paint()..color = _crashColor);
        continue;
      }
      canvas.drawRect(r.deflate(1), edge);
      canvas.drawRect(r.deflate(cell * 0.25), center);
    }

    // Ojitos mirando hacia donde va (cabeza menos el cuello).
    final h = s.first;
    final dx = s.length > 1 ? h.x - s[1].x : 1;
    final dy = s.length > 1 ? h.y - s[1].y : 0;
    final e = cell / 5; // la cabeza se divide en 5 × 5 pixeles
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = snakePupil;
    for (final side in const [-1, 1]) {
      final ex = 2 + dx + side * dy.abs();
      final ey = 2 + dy + side * dx.abs();
      final eye = Rect.fromLTWH(h.x * cell + ex * e, h.y * cell + ey * e, e, e);
      canvas.drawRect(eye, white);
      canvas.drawRect(eye.deflate(e * 0.25), pupil);
    }
  }

  // Es baratico de dibujar, así que siempre redibujamos.
  @override
  bool shouldRepaint(PixelBoardPainter old) => true;
}
