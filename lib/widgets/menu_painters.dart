import 'dart:math';

import 'package:flutter/material.dart';

import '../game/food.dart';
import 'food_painter.dart';
import 'snake_colors.dart';

// Fondo del menú: degradado verde + cuadriculado muy sutil + bordes oscuros
// (viñeta), para que parezca el campo visto de lejos.
class FieldBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5E9B37), Color(0xFF2E5A1C)],
        ).createShader(rect),
    );

    const cs = 44.0; // tamaño de los cuadritos de fondo
    final checker = Paint()..color = Colors.white.withValues(alpha: 0.045);
    for (var x = 0; x * cs < size.width; x++) {
      for (var y = 0; y * cs < size.height; y++) {
        if ((x + y).isEven) {
          canvas.drawRect(Rect.fromLTWH(x * cs, y * cs, cs, cs), checker);
        }
      }
    }

    // Viñeta: transparente en el centro y oscuro en las esquinas.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(FieldBackgroundPainter old) => false; // nunca cambia
}

// El logo: una mapanare ondulando hacia la comida elegida.
// `phase` va de 0 a 1 y la animación la va cambiando: eso mueve la onda.
class LogoSnakePainter extends CustomPainter {
  LogoSnakePainter({required this.phase, required this.food});

  final double phase;
  final Food food;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final thick = h * 0.26; // grosor del cuerpo
    final foodCell = h * 0.6;
    final cy = h * 0.5;

    final tailX = thick * 0.6;
    final headX = w - foodCell * 1.25;
    final amp = h * 0.2;
    final k = 2 * pi * 1.6 / (headX - tailX); // 1.6 ondas a lo largo

    // La onda: y = seno(x). Restar `phase` hace que la onda "viaje".
    // Multiplicar por (1 - 0.6 * t) hace que cerca de la cabeza ondule
    // menos, como cuando la culebra apunta hacia su presa.
    Offset at(double x) {
      final t = (x - tailX) / (headX - tailX);
      final y = cy + amp * (1 - 0.6 * t) * sin((x - tailX) * k - phase * 2 * pi);
      return Offset(x, y);
    }

    const steps = 60;
    final body = Path()..moveTo(tailX, at(tailX).dy);
    for (var i = 1; i <= steps; i++) {
      final p = at(tailX + (headX - tailX) * i / steps);
      body.lineTo(p.dx, p.dy);
    }

    Paint rope(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // Comida primero, para que la culebra quede por encima si se acerca.
    drawFood(canvas, food, Offset(w - foodCell * 0.55, cy), foodCell);

    // Mismo estilo que en el tablero: sombra, borde y centro.
    final head = at(headX);
    final shadowShift = Offset(0, h * 0.04);
    final shadow = Colors.black.withValues(alpha: 0.2);
    canvas.drawPath(body.shift(shadowShift), rope(shadow, thick));
    canvas.drawCircle(head + shadowShift, thick * 0.6, Paint()..color = shadow);
    canvas.drawPath(body, rope(snakeEdge, thick));
    canvas.drawPath(body, rope(snakeCenter, thick * 0.64));
    canvas.drawCircle(head, thick * 0.6, Paint()..color = snakeEdge);
    canvas.drawCircle(head, thick * 0.43, Paint()..color = snakeCenter);

    // Dirección de la cabeza: del punto anterior a la cabeza, normalizada
    // (dividir entre su largo para que mida 1).
    final before = at(headX - 1);
    var dir = head - before;
    dir = dir / dir.distance;
    final side = Offset(-dir.dy, dir.dx);

    final forward = dir * (thick * 0.17);
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = snakePupil;
    for (final eye in [
      head + forward + side * (thick * 0.26),
      head + forward - side * (thick * 0.26),
    ]) {
      canvas.drawCircle(eye, thick * 0.17, white);
      final p = eye + dir * (thick * 0.06);
      canvas.drawCircle(p, thick * 0.09, pupil);
      canvas.drawCircle(p - Offset(thick * 0.03, thick * 0.03), thick * 0.03, white);
    }
  }

  @override
  bool shouldRepaint(LogoSnakePainter old) =>
      old.phase != phase || old.food != food;
}

// Iconito de cuadrícula para los botones de tamaño: más cuadritos = campo
// más grande.
class GridIconPainter extends CustomPainter {
  GridIconPainter(this.n);

  final int n;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.18)));
    final cs = size.width / n;
    final light = Paint()..color = const Color(0xFF8CC657);
    final dark = Paint()..color = const Color(0xFF6EA83C);
    for (var x = 0; x < n; x++) {
      for (var y = 0; y < n; y++) {
        canvas.drawRect(
            Rect.fromLTWH(x * cs, y * cs, cs + 0.5, cs + 0.5),
            (x + y).isEven ? light : dark);
      }
    }
  }

  @override
  bool shouldRepaint(GridIconPainter old) => old.n != n;
}
