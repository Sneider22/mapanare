import 'dart:math';

import 'package:flutter/material.dart';

import '../game/food.dart';

// Dibuja una comida centrada en `c`, del tamaño de una casilla (`cell`).
// Es una función suelta para usarla en el tablero y en el menú.
void drawFood(Canvas canvas, Food food, Offset c, double cell) {
  final r = cell * 0.42; // "radio" base: todo se mide en relación a esto

  // Sombrita debajo de cualquier comida.
  canvas.drawOval(
    Rect.fromCenter(
      center: c.translate(0, r * 0.8),
      width: r * 1.6,
      height: r * 0.4,
    ),
    Paint()..color = Colors.black.withValues(alpha: 0.18),
  );

  // `switch` sobre un enum: Dart te obliga a cubrir todas las opciones.
  switch (food) {
    case Food.arepa:
      _arepa(canvas, c, r);
    case Food.mango:
      _mango(canvas, c, r);
    case Food.hamburguesa:
      _hamburguesa(canvas, c, r);
    case Food.pollo:
      _pollo(canvas, c, r);
    case Food.hayaca:
      _hayaca(canvas, c, r);
    case Food.tequeno:
      _tequeno(canvas, c, r);
  }
}

void _arepa(Canvas canvas, Offset c, double r) {
  canvas.drawCircle(c, r, Paint()..color = const Color(0xFFD9A55B));
  canvas.drawCircle(c, r * 0.85, Paint()..color = const Color(0xFFF3D9A4));
  final spot = Paint()..color = const Color(0xFFB5793A); // tostado del budare
  canvas.drawCircle(c.translate(-r * 0.35, -r * 0.25), r * 0.12, spot);
  canvas.drawCircle(c.translate(r * 0.3, -r * 0.1), r * 0.09, spot);
  canvas.drawCircle(c.translate(-r * 0.05, r * 0.35), r * 0.1, spot);
}

void _mango(Canvas canvas, Offset c, double r) {
  // save/translate/rotate: movemos y giramos el lienzo para dibujar
  // el mango inclinado, y restore() lo deja como estaba.
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-0.5);

  final body = Rect.fromCenter(
    center: Offset.zero,
    width: r * 1.55,
    height: r * 1.95,
  );
  // Degradado amarillo -> naranja -> rojo, como un mango maduro.
  canvas.drawOval(
    body,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.9,
        colors: [Color(0xFFFFE082), Color(0xFFFFA726), Color(0xFFE53935)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(body),
  );

  canvas.drawLine(
    Offset(0, -r * 0.95),
    Offset(0, -r * 1.15),
    Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round,
  );
  final leaf = Path()
    ..moveTo(0, -r * 1.05)
    ..quadraticBezierTo(r * 0.6, -r * 1.45, r * 0.85, -r * 0.95)
    ..quadraticBezierTo(r * 0.35, -r * 0.85, 0, -r * 1.05)
    ..close();
  canvas.drawPath(leaf, Paint()..color = const Color(0xFF2E7D32));
  canvas.restore();
}

void _hamburguesa(Canvas canvas, Offset c, double r) {
  // Se dibuja de abajo hacia arriba: lo último queda encima.
  final l = c.dx - r * 0.95;
  final rt = c.dx + r * 0.95;
  final bun = Paint()..color = const Color(0xFFE09B4B);

  canvas.drawRRect(
    RRect.fromLTRBR(l + r * 0.05, c.dy + r * 0.28, rt - r * 0.05,
        c.dy + r * 0.65, Radius.circular(r * 0.18)),
    bun,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
        l, c.dy - r * 0.05, rt, c.dy + r * 0.32, Radius.circular(r * 0.15)),
    Paint()..color = const Color(0xFF5D3A1A),
  );
  final cheese = Path()
    ..moveTo(l, c.dy - r * 0.12)
    ..lineTo(rt, c.dy - r * 0.12)
    ..lineTo(rt, c.dy + r * 0.02)
    ..lineTo(c.dx + r * 0.2, c.dy + r * 0.02)
    ..lineTo(c.dx, c.dy + r * 0.22)
    ..lineTo(c.dx - r * 0.2, c.dy + r * 0.02)
    ..lineTo(l, c.dy + r * 0.02)
    ..close();
  canvas.drawPath(cheese, Paint()..color = const Color(0xFFFFC107));
  canvas.drawRRect(
    RRect.fromLTRBR(l - r * 0.05, c.dy - r * 0.34, rt + r * 0.05,
        c.dy - r * 0.12, Radius.circular(r * 0.09)),
    Paint()..color = const Color(0xFF43A047),
  );
  // Pan de arriba: media elipse (arco de 180° desde la izquierda).
  canvas.drawArc(
    Rect.fromLTRB(l, c.dy - r * 0.95, rt, c.dy + r * 0.35),
    pi,
    pi,
    true,
    bun,
  );
  final seed = Paint()..color = const Color(0xFFFFF3D6);
  for (final s in const [
    Offset(-0.4, -0.6),
    Offset(0, -0.75),
    Offset(0.4, -0.6),
    Offset(-0.15, -0.47),
    Offset(0.22, -0.45),
  ]) {
    canvas.drawOval(
      Rect.fromCenter(
          center: c + s * r, width: r * 0.14, height: r * 0.08),
      seed,
    );
  }
}

void _pollo(Canvas canvas, Offset c, double r) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-pi / 4); // el hueso apunta hacia arriba a la derecha

  final bone = Paint()..color = const Color(0xFFF5EBDC);
  canvas.drawRRect(
    RRect.fromLTRBR(
        r * 0.2, -r * 0.11, r * 0.85, r * 0.11, Radius.circular(r * 0.05)),
    bone,
  );
  canvas.drawCircle(Offset(r * 0.88, -r * 0.13), r * 0.15, bone);
  canvas.drawCircle(Offset(r * 0.88, r * 0.13), r * 0.15, bone);

  final meat = Rect.fromCenter(
    center: Offset(-r * 0.2, 0),
    width: r * 1.35,
    height: r * 1.05,
  );
  canvas.drawOval(meat, Paint()..color = const Color(0xFFB8641F));
  canvas.drawOval(meat.deflate(r * 0.1), Paint()..color = const Color(0xFFD9893A));
  final crispy = Paint()..color = const Color(0xFF9A4F15); // lo crujiente
  for (final d in const [
    Offset(-0.5, -0.15),
    Offset(-0.2, 0.2),
    Offset(0.05, -0.2),
    Offset(-0.35, 0.3),
    Offset(0.15, 0.15),
  ]) {
    canvas.drawCircle(Offset(r * d.dx, r * d.dy), r * 0.07, crispy);
  }
  canvas.restore();
}

void _hayaca(Canvas canvas, Offset c, double r) {
  // Rectángulo envuelto en hoja de plátano y amarrado con pabilo.
  final rect = Rect.fromCenter(center: c, width: r * 1.8, height: r * 1.3);
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(r * 0.12)),
    Paint()..color = const Color(0xFF1F4D17),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect.deflate(r * 0.08), Radius.circular(r * 0.08)),
    Paint()..color = const Color(0xFF2F6B22),
  );
  final vein = Paint()
    ..color = const Color(0xFF4C8A35)
    ..strokeWidth = r * 0.04;
  for (var i = 1; i <= 3; i++) {
    final y = rect.top + rect.height * i / 4;
    canvas.drawLine(
        Offset(rect.left + r * 0.12, y), Offset(rect.right - r * 0.12, y), vein);
  }
  final pabilo = Paint()
    ..color = const Color(0xFFF1E6C8)
    ..strokeWidth = r * 0.09
    ..strokeCap = StrokeCap.round;
  for (final x in [c.dx - r * 0.35, c.dx + r * 0.35]) {
    canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), pabilo);
  }
  canvas.drawLine(Offset(rect.left, c.dy), Offset(rect.right, c.dy), pabilo);
}

void _tequeno(Canvas canvas, Offset c, double r) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-0.4); // inclinadito

  // El queso blanco asomándose por la punta (va primero para que la
  // masa lo tape a la mitad).
  canvas.drawOval(
    Rect.fromCenter(center: Offset(r * 0.98, 0), width: r * 0.34, height: r * 0.44),
    Paint()..color = const Color(0xFFFFF8E1),
  );

  // El palito de masa dorada.
  final stick = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: r * 2.0, height: r * 0.78),
    Radius.circular(r * 0.39),
  );
  canvas.drawRRect(stick, Paint()..color = const Color(0xFFE3A857));

  // clipRRect: todo lo que dibuje ahora solo se ve DENTRO del palito.
  // Así las rayas diagonales de la masa enrollada no se salen.
  canvas.save();
  canvas.clipRRect(stick);
  final wrap = Paint()
    ..color = const Color(0xFFC2843A)
    ..strokeWidth = r * 0.1;
  for (var x = -r * 1.2; x <= r * 1.2; x += r * 0.38) {
    canvas.drawLine(Offset(x - r * 0.2, -r * 0.45), Offset(x + r * 0.2, r * 0.45), wrap);
  }
  // Brillito de fritura arriba.
  canvas.drawRRect(
    RRect.fromLTRBR(-r * 0.75, -r * 0.3, r * 0.6, -r * 0.15, Radius.circular(r * 0.08)),
    Paint()..color = const Color(0xFFF6D28E).withValues(alpha: 0.8),
  );
  canvas.restore(); // quita el recorte
  canvas.restore(); // quita la rotación
}


// Painter pequeñito para mostrar una comida sola (el ícono del menú).
class FoodIconPainter extends CustomPainter {
  FoodIconPainter(this.food);

  final Food food;

  @override
  void paint(Canvas canvas, Size size) {
    drawFood(canvas, food, size.center(Offset.zero), size.shortestSide);
  }

  @override
  bool shouldRepaint(FoodIconPainter old) => old.food != food;
}
