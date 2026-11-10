import 'dart:math';

import 'package:flutter/material.dart';

// PIXEL ART con texto: cada String es una fila y cada letra es un pixel.
// La letra dice qué color usar (según `palette`) y el punto '.' es vacío.
// Así puedes "dibujar" un sprite escribiéndolo, sin abrir ningún editor.
class Sprite {
  const Sprite(this.rows, this.palette);

  final List<String> rows;
  final Map<String, Color> palette;

  int get width => rows.map((r) => r.length).reduce(max);
  int get height => rows.length;

  // Dibuja el sprite con su esquina de arriba a la izquierda en `origin`.
  // `px` = cuánto mide cada pixel en pantalla.
  void paintAt(Canvas canvas, Offset origin, double px) {
    final paint = Paint();
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        final color = palette[row[x]];
        if (color == null) continue; // '.' u otra letra sin color = vacío
        paint.color = color;
        // El + 0.5 tapa las rayitas finas que a veces quedan entre pixeles.
        canvas.drawRect(
          Rect.fromLTWH(
            origin.dx + x * px,
            origin.dy + y * px,
            px + 0.5,
            px + 0.5,
          ),
          paint,
        );
      }
    }
  }

  // Lo dibuja lo más grande posible dentro de `area`, centrado.
  void paintIn(Canvas canvas, Rect area) {
    final px = min(area.width / width, area.height / height);
    final origin = area.center - Offset(width * px / 2, height * px / 2);
    paintAt(canvas, origin, px);
  }
}

// Para usar un sprite como widget (por ejemplo, el ícono de una tarjeta).
class SpritePainter extends CustomPainter {
  SpritePainter(this.sprite);

  final Sprite sprite;

  @override
  void paint(Canvas canvas, Size size) =>
      sprite.paintIn(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(SpritePainter old) => old.sprite != sprite;
}
