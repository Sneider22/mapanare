import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../arcade/arcade_style.dart';
import '../game/snake_game.dart';
import '../howto/scenes.dart';
import '../widgets/arcade_widgets.dart';
import '../widgets/pixel_board.dart';

// CÓMO JUGAR: 3 "videos" (lo básico, el anís y el apagón). Cada video
// tiene capítulos; mientras pasa cada capítulo, abajo se va escribiendo su
// explicación. Los videos están en lib/howto/scenes.dart.
class HowToScreen extends StatefulWidget {
  const HowToScreen({super.key});

  @override
  State<HowToScreen> createState() => _HowToScreenState();
}

class _HowToScreenState extends State<HowToScreen>
    with SingleTickerProviderStateMixin {
  static const _cell = 26.0; // tamaño de cada casilla de la escena

  int _page = 0;
  Duration _now = Duration.zero; // reloj del Ticker
  Duration _pageStart = Duration.zero; // cuándo se abrió la página actual

  // El reloj que mueve el video y escribe el texto. OJO: hay que
  // arrancarlo en initState. Si se deja como `late ... ..start()`, Dart
  // solo lo crea cuando alguien lo usa por primera vez... y el reloj
  // nunca arranca (ese fue el error que congelaba los videos).
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => setState(() => _now = elapsed))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  HowToScene get _scene => howToScenes[_page];
  int get _ms => (_now - _pageStart).inMilliseconds;
  bool get _isLast => _page == howToScenes.length - 1;

  void _go(int delta) {
    final next = _page + delta;
    if (next < 0) return;
    if (next >= howToScenes.length) {
      Navigator.of(context).pop(); // en la última, "LISTO" vuelve al Inicio
      return;
    }
    setState(() {
      _page = next;
      _pageStart = _now; // la escena y el texto arrancan de cero
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _go(1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _go(-1);
    } else if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    // El video se repite: `% frames.length` vuelve al principio.
    final index = (_ms ~/ scene.stepMs) % scene.frames.length;
    final frame = scene.frames[index];
    final chapter = scene.chapters[frame.chapter];
    // Cuánto tiempo lleva el capítulo actual (para escribir su texto).
    final chapterMs =
        (_ms % (scene.frames.length * scene.stepMs)) -
        chapter.startFrame * scene.stepMs;

    return ArcadeScaffold(
      onKey: _onKey,
      // Deslizar a los lados también cambia de página.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v < -200) _go(1);
          if (v > 200) _go(-1);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '> ${scene.title}',
                  style: pixelText(9, neonBlue, glow: 4),
                ),
              ),
              const SizedBox(height: 10),
              _buildBoard(frame),
              const SizedBox(height: 6),
              _buildProgress(scene, index),
              const SizedBox(height: 8),
              _buildStatus(frame),
              const SizedBox(height: 8),
              SizedBox(
                height: 66,
                child: scene.showKeys
                    ? CustomPaint(
                        size: const Size(100, 66),
                        painter: _KeysPainter(frame.pressed),
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              _buildText(scene, frame.chapter, chapterMs),
              const Spacer(),
              _buildNav(),
            ],
          ),
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
        Text('CÓMO JUGAR', style: pixelText(10, neonYellow, glow: 6)),
        const Spacer(),
        Text(
          '${_page + 1}/${howToScenes.length}',
          style: pixelText(8, Colors.white38),
        ),
      ],
    );
  }

  Widget _buildBoard(SceneFrame frame) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: neonGreen.withValues(alpha: 0.7), width: 3),
        boxShadow: [
          BoxShadow(color: neonGreen.withValues(alpha: 0.2), blurRadius: 12),
        ],
      ),
      child: SizedBox(
        width: _cell * sceneCols,
        height: _cell * sceneRows,
        child: CustomPaint(painter: PixelBoardPainter(frame.view)),
      ),
    );
  }

  // Debajo del tablero: el letrero de la escena y los puntos.
  // Barrita de progreso del video, partida en un pedazo por capítulo.
  // El capítulo actual se va llenando de amarillo.
  Widget _buildProgress(HowToScene scene, int index) {
    return SizedBox(
      width: _cell * sceneCols + 6,
      height: 6,
      child: Row(
        children: [
          for (final (i, c) in scene.chapters.indexed)
            Expanded(
              flex: c.length,
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                color: Colors.white12,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ((index - c.startFrame) / c.length).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Container(color: neonYellow),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(SceneFrame frame) {
    final banner = frame.banner;
    final bannerColor = banner == 'CHOCASTE' ? neonRed : neonYellow;
    return SizedBox(
      height: 14,
      child: Row(
        children: [
          if (banner != null)
            Text(banner, style: pixelText(7, bannerColor, glow: 4)),
          const Spacer(),
          Text(
            'PUNTOS ${frame.score.toString().padLeft(3, '0')}',
            style: pixelText(7, Colors.white70),
          ),
        ],
      ),
    );
  }

  // El texto del capítulo aparece letra por letra, con un cursor que
  // parpadea al final.
  Widget _buildText(HowToScene scene, int chapterIndex, int chapterMs) {
    final chapter = scene.chapters[chapterIndex];
    final text = chapter.text;
    final shown = (chapterMs ~/ typeMs).clamp(0, text.length);
    final done = shown == text.length;
    final cursorOn = (_ms ~/ 400).isEven;
    return Container(
      width: double.infinity,
      height: 146,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: arcadePanel,
        border: Border.all(color: Colors.white24, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(chapter.title, style: pixelText(8, neonYellow, glow: 4)),
              const Spacer(),
              Text(
                '${chapterIndex + 1}/${scene.chapters.length}',
                style: pixelText(7, Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text.substring(0, shown) + (!done || cursorOn ? '_' : ' '),
            style: pixelText(8, Colors.white).copyWith(height: 1.9),
          ),
        ],
      ),
    );
  }

  // Abajo: anterior, puntitos de página y siguiente.
  Widget _buildNav() {
    return Row(
      children: [
        Opacity(
          opacity: _page == 0 ? 0.3 : 1,
          child: PixelButton(label: '<', color: neonBlue, onTap: () => _go(-1)),
        ),
        const Spacer(),
        for (var i = 0; i < howToScenes.length; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            color: i == _page ? neonYellow : Colors.white24,
          ),
        const Spacer(),
        PixelButton(
          label: _isLast ? 'LISTO' : '>',
          color: _isLast ? neonYellow : neonBlue,
          onTap: () => _go(1),
        ),
      ],
    );
  }
}

// Las 4 flechas en cruz, como un control. La que se está "apretando"
// se ilumina en amarillo y se hunde un poquito.
class _KeysPainter extends CustomPainter {
  _KeysPainter(this.pressed);

  final Direction? pressed;

  static const _key = 30.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final positions = {
      Direction.up: Offset(cx, _key / 2),
      Direction.left: Offset(cx - _key - _gap, _key * 1.5 + _gap),
      Direction.down: Offset(cx, _key * 1.5 + _gap),
      Direction.right: Offset(cx + _key + _gap, _key * 1.5 + _gap),
    };

    for (final MapEntry(key: dir, value: center) in positions.entries) {
      final on = dir == pressed;
      final rect = Rect.fromCenter(
        center: center + Offset(0, on ? 2 : 0),
        width: _key,
        height: _key,
      );
      canvas.drawRect(rect, Paint()..color = on ? neonYellow : arcadePanel);
      canvas.drawRect(
        rect,
        Paint()
          ..color = on ? Colors.black : Colors.white38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Flechita: un triángulo que apunta hacia la dirección.
      final c = rect.center;
      final t = _key * 0.22;
      final tip = c + Offset(dir.dx * t, dir.dy * t);
      final side = Offset(dir.dy.toDouble(), dir.dx.toDouble()) * t;
      final back = c - Offset(dir.dx * t, dir.dy * t) * 0.6;
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo((back + side).dx, (back + side).dy)
        ..lineTo((back - side).dx, (back - side).dy)
        ..close();
      canvas.drawPath(path, Paint()..color = on ? arcadeBg : Colors.white70);
    }
  }

  @override
  bool shouldRepaint(_KeysPainter old) => old.pressed != pressed;
}
