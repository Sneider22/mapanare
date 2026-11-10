import 'dart:math';

import 'package:flutter/material.dart';

import '../arcade/arcade_style.dart';
import '../game/food.dart';
import 'pixel_foods.dart';
import 'snake_colors.dart';

// ===== DEMO DEL INICIO =====
// Una culebrita de cuadritos que le da la vuelta a una "pistica"
// rectangular y se va comiendo arepas. Como las maquinitas que juegan
// solas mientras nadie echa moneda.
class DemoSnakePainter extends CustomPainter {
  DemoSnakePainter(this.step);

  final int step; // en qué paso va (sube de 1 en 1)

  static const cols = 18;
  static const rows = 5;
  static const _length = 6;

  // El recorrido: una vuelta completa por dentro del tablerito.
  // `static final` = se calcula una sola vez para todos.
  static final List<Point<int>> path = _buildPath();
  static int get pathLength => path.length;

  static List<Point<int>> _buildPath() {
    final p = <Point<int>>[];
    for (var x = 1; x <= 16; x++) {
      p.add(Point(x, 1)); // fila de arriba, hacia la derecha
    }
    for (var y = 2; y <= 3; y++) {
      p.add(Point(16, y)); // baja por la derecha
    }
    for (var x = 15; x >= 1; x--) {
      p.add(Point(x, 3)); // fila de abajo, hacia la izquierda
    }
    p.add(const Point(1, 2)); // sube y cierra la vuelta
    return p;
  }

  // En qué puntos del recorrido aparecen las arepas.
  static const _foodSpots = [9, 20, 30];

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / cols;
    final n = path.length;
    final head = step % n;

    // Fondo: campo verde oscuro a cuadros.
    final dark = Paint()..color = const Color(0xFF12301B);
    final light = Paint()..color = const Color(0xFF163A21);
    for (var x = 0; x < cols; x++) {
      for (var y = 0; y < rows; y++) {
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          (x + y).isEven ? dark : light,
        );
      }
    }

    // La arepa que toca: la próxima que está ADELANTE de la cabeza.
    // Cuando la cabeza pasa por encima, "se la come" y sale la siguiente.
    var nextSpot = _foodSpots.first;
    var bestDist = n + 1;
    for (final s in _foodSpots) {
      final dist = (s - head) % n; // % en Dart nunca da negativo
      if (dist > 0 && dist < bestDist) {
        bestDist = dist;
        nextSpot = s;
      }
    }
    final food = path[nextSpot];
    final foodRect = Rect.fromLTWH(food.x * cell, food.y * cell, cell, cell);
    foodSprites[Food.arepa]!.paintIn(canvas, foodRect.deflate(cell * 0.05));

    // La culebra: de la cola a la cabeza, para que la cabeza quede encima.
    final edge = Paint()..color = snakeEdge;
    final center = Paint()..color = snakeCenter;
    for (var i = _length - 1; i >= 0; i--) {
      final p = path[(head - i) % n];
      final r = Rect.fromLTWH(p.x * cell, p.y * cell, cell, cell);
      canvas.drawRect(r.deflate(1), edge);
      canvas.drawRect(r.deflate(cell * 0.25), center);
    }

    // Ojitos: dos pixeles blancos mirando hacia donde va.
    final h = path[head];
    final prev = path[(head - 1) % n];
    final dx = h.x - prev.x;
    final dy = h.y - prev.y;
    final e = cell / 5; // la cabeza se divide en una cuadrícula de 5 × 5
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

  @override
  bool shouldRepaint(DemoSnakePainter old) => old.step != step;
}

// ===== BOMBILLOS =====
// Lucecitas alrededor del letrero, como las de una feria. Se van
// prendiendo y apagando intercaladas, en amarillo, azul y rojo.
class MarqueeLightsPainter extends CustomPainter {
  MarqueeLightsPainter(this.phase);

  final int phase;

  static const _gap = 16.0; // distancia entre bombillos
  static const _bulb = 5.0; // tamaño de cada bombillo
  static const _inset = 7.0; // qué tan adentro del borde van

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(
      _inset,
      _inset,
      size.width - _inset * 2,
      size.height - _inset * 2,
    );

    // Puntos a lo largo de los 4 lados del rectángulo.
    final points = <Offset>[];
    void side(Offset a, Offset b) {
      final steps = ((b - a).distance / _gap).floor();
      for (var i = 0; i < steps; i++) {
        points.add(Offset.lerp(a, b, i / steps)!);
      }
    }

    side(r.topLeft, r.topRight);
    side(r.topRight, r.bottomRight);
    side(r.bottomRight, r.bottomLeft);
    side(r.bottomLeft, r.topLeft);

    const colors = [neonYellow, neonBlue, neonRed];
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final dot = Paint();
    for (var i = 0; i < points.length; i++) {
      final lit = (i + phase).isEven;
      final c = colors[i % 3];
      final rect = Rect.fromCenter(
        center: points[i],
        width: _bulb,
        height: _bulb,
      );
      if (lit) {
        glow.color = c.withValues(alpha: 0.7);
        canvas.drawRect(rect.inflate(2), glow);
      }
      dot.color = lit ? c : c.withValues(alpha: 0.22);
      canvas.drawRect(rect, dot);
    }
  }

  @override
  bool shouldRepaint(MarqueeLightsPainter old) => old.phase != phase;
}

// ===== PANTALLA DE TUBO =====
// Rayitas horizontales finitas y bordes oscuros, como un televisor viejo.
// Va encima de todo y no bloquea los toques (IgnorePointer en la pantalla).
class CrtPainter extends CustomPainter {
  const CrtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = Colors.black.withValues(alpha: 0.16);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.1,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
          stops: const [0.6, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(CrtPainter old) => false;
}
