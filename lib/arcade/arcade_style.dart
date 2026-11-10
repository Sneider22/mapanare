import 'package:flutter/material.dart';

// Todo el "look" de maquinita en un solo lugar: colores neón y la letra
// pixelada. Si quieres cambiar el estilo del juego, empieza por aquí.

const arcadeBg = Color(0xFF0E0B1F); // casi negro, un poquito morado
const arcadePanel = Color(0xFF1A1433); // un tono más claro, para cajas
const neonYellow = Color(0xFFFFD60A);
const neonBlue = Color(0xFF3A86FF);
const neonRed = Color(0xFFFF3B5C);
const neonGreen = Color(0xFF7CFC6A);
const invertedPurple = Color(0xFFB58AD9); // culebra con los controles al revés

const pixelFont = 'PressStart2P'; // el nombre que le pusimos en pubspec.yaml

// Atajo para no repetir siempre lo mismo. `glow` > 0 le pone un brillo
// alrededor a las letras, como un letrero de neón.
TextStyle pixelText(double size, Color color, {double glow = 0}) {
  return TextStyle(
    fontFamily: pixelFont,
    fontSize: size,
    color: color,
    height: 1.4,
    shadows: glow > 0
        ? [Shadow(color: color.withValues(alpha: 0.8), blurRadius: glow)]
        : null,
  );
}
