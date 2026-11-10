import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../arcade/arcade_style.dart';
import '../game/board_size.dart';
import '../game/food.dart';
import '../game/game_mode.dart';
import '../widgets/arcade_widgets.dart';
import '../widgets/pixel_foods.dart';
import '../widgets/pixel_sprite.dart';
import 'game_screen.dart';

// PREPARAR PARTIDA: modo, campo y comida, todo en una sola pantalla.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  GameMode _mode = GameMode.clasico;
  BoardSize _size = BoardSize.mediano;
  Food _food = Food.arepa;

  // Ancho útil de la hoja (360) menos el margen de los lados (20 + 20).
  static const _inner = 320.0;
  static const _gap = 8.0;
  // Ancho de cada tarjeta cuando van 3 por fila.
  static const _third = (_inner - _gap * 2) / 3;

  void _play() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(size: _size, food: _food, mode: _mode),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _play();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return ArcadeScaffold(
      onKey: _onKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),
            const _SectionTitle('MODO'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final m in GameMode.values)
                  ArcadeTile(
                    width: (_inner - _gap) / 2,
                    height: 62,
                    selected: m == _mode,
                    onTap: () => setState(() => _mode = m),
                    label: m.label,
                    caption: m.caption,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle('CAMPO'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in BoardSize.values)
                  ArcadeTile(
                    width: _third,
                    height: 84,
                    selected: s == _size,
                    onTap: () => setState(() => _size = s),
                    // 4, 6 u 8 cuadritos según el tamaño, para que se note
                    // la diferencia de un vistazo.
                    icon: SizedBox(
                      width: 26,
                      height: 26,
                      child: CustomPaint(
                        painter: _GridIconPainter(4 + 2 * s.index),
                      ),
                    ),
                    label: s.label.toUpperCase(),
                    caption: '${s.cells}x${s.cells}',
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle('COMIDA'),
            // Wrap acomoda las 6 tarjetas en filas de 3: siempre 3 × 2.
            Wrap(
              spacing: _gap,
              runSpacing: _gap,
              children: [
                for (final f in Food.values)
                  ArcadeTile(
                    width: _third,
                    height: 76,
                    selected: f == _food,
                    onTap: () => setState(() => _food = f),
                    icon: SizedBox(
                      width: 36,
                      height: 36,
                      child: CustomPaint(
                        painter: SpritePainter(foodSprites[f]!),
                      ),
                    ),
                    label: f.label.toUpperCase(),
                  ),
              ],
            ),
            const Spacer(),
            PixelButton(
              label: 'JUGAR',
              color: neonYellow,
              big: true,
              onTap: _play,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        PixelButton(
          label: '<',
          color: neonBlue,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 16),
        Text('PREPARA TU PARTIDA', style: pixelText(10, neonYellow, glow: 6)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('> $text', style: pixelText(8, neonBlue, glow: 4)),
      ),
    );
  }
}

// Cuadrícula chiquita de n × n en verde, como el campo visto de lejos.
class _GridIconPainter extends CustomPainter {
  _GridIconPainter(this.n);

  final int n;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / n;
    final dark = Paint()..color = const Color(0xFF2E7D32);
    final light = Paint()..color = const Color(0xFF43A047);
    for (var x = 0; x < n; x++) {
      for (var y = 0; y < n; y++) {
        canvas.drawRect(
          Rect.fromLTWH(x * c, y * c, c, c),
          (x + y).isEven ? dark : light,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridIconPainter old) => old.n != n;
}
