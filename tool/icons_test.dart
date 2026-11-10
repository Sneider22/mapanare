// Genera el favicon y los íconos de la web (web/favicon.png y web/icons/).
// Uso: flutter test tool/icons_test.dart
//
// El ícono es una culebra en forma de "S" en pixel art. Se dibuja sobre
// una cuadrícula de 32 × 32 "puntitos": a 32 px cada puntito es 1 pixel
// exacto (nítido), y en los tamaños grandes solo se agranda.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/arcade/arcade_style.dart';
import 'package:mapanare/widgets/snake_colors.dart';

// La culebra en casillas de 8 × 8 (cada casilla = 4 × 4 puntitos).
// H = cabeza (mira a la izquierda), B = cuerpo.
const _layout = [
  '........',
  '..BBBBB.',
  '..B.....',
  '..BBBBB.',
  '......B.',
  '.HBBBBB.',
  '........',
  '........',
];

// Corrimiento en puntitos para que el dibujo quede centrado.
const _offsetX = 1;
const _offsetY = 2;

void _paintIcon(Canvas canvas, double size, {required bool maskable}) {
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), Paint()..color = arcadeBg);

  // Los íconos "maskable" (Android) se recortan en círculo: el dibujo va
  // más pequeño, dentro de la zona segura, y sin borde.
  final scale = maskable ? 0.66 : 1.0;
  final unit = size * scale / 32;
  final origin = Offset((size - unit * 32) / 2, (size - unit * 32) / 2);

  void dot(num x, num y, Color color, [num w = 1, num h = 1]) {
    canvas.drawRect(
      Rect.fromLTWH(
        origin.dx + (x + _offsetX) * unit,
        origin.dy + (y + _offsetY) * unit,
        w * unit,
        h * unit,
      ),
      Paint()..color = color,
    );
  }

  if (!maskable) {
    // Marco verde neón, como el borde del tablero.
    final border = Paint()
      ..color = neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit;
    canvas.drawRect(
      Rect.fromLTWH(unit / 2, unit / 2, size - unit, size - unit),
      border,
    );
  }

  for (var cy = 0; cy < 8; cy++) {
    for (var cx = 0; cx < 8; cx++) {
      final c = _layout[cy][cx];
      if (c == '.') continue;
      final x = cx * 4, y = cy * 4;
      dot(x, y, snakeEdge, 4, 4);
      if (c == 'B') {
        dot(x + 1, y + 1, snakeCenter, 2, 2);
      } else {
        // Cabeza: ojos arriba y abajo, y la lengüita roja bifurcada.
        dot(x + 1, y, Colors.white);
        dot(x + 1, y + 3, Colors.white);
        dot(x - 1, y + 1, neonRed, 1, 2);
        dot(x - 2, y, neonRed);
        dot(x - 2, y + 3, neonRed);
      }
    }
  }
}

Future<void> _save(String path, int size, {bool maskable = false}) async {
  final recorder = ui.PictureRecorder();
  _paintIcon(Canvas(recorder), size.toDouble(), maskable: maskable);
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('íconos', (tester) async {
    await tester.runAsync(() async {
      await _save('web/favicon.png', 32);
      await _save('web/icons/Icon-192.png', 192);
      await _save('web/icons/Icon-512.png', 512);
      await _save('web/icons/Icon-maskable-192.png', 192, maskable: true);
      await _save('web/icons/Icon-maskable-512.png', 512, maskable: true);
    });
  });
}
