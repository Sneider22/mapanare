import 'package:flutter/material.dart';

import '../game/food.dart';
import 'pixel_sprite.dart';

// Las 6 comidas en pixel art. Para cambiar una, cambia las letras:
// cada letra es un cuadrito y su color está en la paleta de abajo.
// El punto '.' es transparente.

const foodSprites = <Food, Sprite>{
  Food.arepa: _arepa,
  Food.mango: _mango,
  Food.hamburguesa: _hamburguesa,
  Food.pollo: _pollo,
  Food.hayaca: _hayaca,
  Food.tequeno: _tequeno,
};

// d = borde tostado, b = masa, c = centro clarito, t = manchas del budare
const _arepa = Sprite(
  [
    '..dddddd..',
    '.dbbbbbbd.',
    'dbcctcccbd',
    'dbccccctbd',
    'dbccccccbd',
    'dbctccccbd',
    '.dbbbbbbd.',
    '..dddddd..',
  ],
  {
    'd': Color(0xFFB5793A),
    'b': Color(0xFFD9A55B),
    'c': Color(0xFFF3D9A4),
    't': Color(0xFFC98C45),
  },
);

// s = palito, g = hoja, y = amarillo, h = brillo, o = naranja, r = rojo
const _mango = Sprite(
  [
    '......sg..',
    '.....sgg..',
    '...yyyy...',
    '..yyyyoo..',
    '.yyhyyoor.',
    '.yhyyoorr.',
    '.yyyyoorr.',
    '..yyoorr..',
    '...oorr...',
    '....rr....',
  ],
  {
    's': Color(0xFF6B4423),
    'g': Color(0xFF4CAF50),
    'y': Color(0xFFFFD23F),
    'h': Color(0xFFFFF3B0),
    'o': Color(0xFFFF9F1C),
    'r': Color(0xFFE85D2A),
  },
);

// b = pan, h = ajonjolí, l = lechuga, t = tomate, c = queso, m = carne
const _hamburguesa = Sprite(
  [
    '..bbbbbb..',
    '.bhbbbhbb.',
    'bbbbhbbbbb',
    'llllllllll',
    'tttttttttt',
    'cccccccccc',
    'mmmmmmmmmm',
    'bbbbbbbbbb',
    '.bbbbbbbb.',
  ],
  {
    'b': Color(0xFFE0A04A),
    'h': Color(0xFFFFF1C9),
    'l': Color(0xFF6BCB3B),
    't': Color(0xFFE53935),
    'c': Color(0xFFFFC928),
    'm': Color(0xFF6B3A1E),
  },
);

// f = frito, h = brillo, k = tostadito, w = hueso, g = sombra del hueso
const _pollo = Sprite(
  [
    '..ffff....',
    '.fhhfff...',
    'fhhffffk..',
    'fhfffffkk.',
    'ffffffkkk.',
    '.ffffkkk..',
    '..kkkkkw..',
    '.......ww.',
    '......wwgw',
    '.......gw.',
  ],
  {
    'f': Color(0xFFD2873C),
    'h': Color(0xFFF0B060),
    'k': Color(0xFFA0522D),
    'w': Color(0xFFF5F0E6),
    'g': Color(0xFFCFC4B0),
  },
);

// g = hoja de plátano, l = brillo, d = sombra, s = pabilo (el hilo)
const _hayaca = Sprite(
  [
    '.glgsgggd.',
    'glggsggggd',
    'ggggsggdgd',
    'ssssssssss',
    'ggggsggggd',
    'glggsgggdd',
    '.gggsgggd.',
  ],
  {
    'g': Color(0xFF3E7D32),
    'l': Color(0xFF5FA548),
    'd': Color(0xFF2C5E23),
    's': Color(0xFFF0E2C0),
  },
);

// d = borde, g = masa dorada, h = brillo, c = queso que se sale
const _tequeno = Sprite(
  [
    '.dddddddd.',
    'dhghhghhgd',
    'dgggdgggcc',
    'dgdgggdgcc',
    '.dddddddd.',
    '........c.',
  ],
  {
    'd': Color(0xFFC27A2C),
    'g': Color(0xFFE6A64A),
    'h': Color(0xFFF7CF7E),
    'c': Color(0xFFFFF6D6),
  },
);

// LA BOTELLA DE ANÍS (sorpresa del modo Criollo).
// r = tapa roja, g = vidrio, h = brillo del vidrio, w = etiqueta, l = letra
const anisSprite = Sprite(
  [
    '...rr...',
    '...rr...',
    '...gh...',
    '...gh...',
    '..gghg..',
    '.gggghg.',
    '.wwwwww.',
    '.wllllw.',
    '.wwwwww.',
    '.gggghg.',
    '.gggghg.',
    '..gggg..',
  ],
  {
    'r': Color(0xFFE53935),
    'g': Color(0xFF7FC8B8),
    'h': Color(0xFFD8F5EE),
    'w': Color(0xFFF5F0E1),
    'l': Color(0xFF1E5AA8),
  },
);
