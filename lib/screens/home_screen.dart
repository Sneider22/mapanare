import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../arcade/arcade_style.dart';
import '../widgets/arcade_painters.dart';
import '../widgets/arcade_widgets.dart';
import 'how_to_screen.dart';
import 'records_screen.dart';
import 'setup_screen.dart';

// PANTALLA DE INICIO: el frente de la maquinita.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _stepMs = 130; // velocidad de la culebrita del demo

  // UN solo reloj para todo: dura justo una vuelta completa del demo y se
  // repite. De ese tiempo sacamos el paso de la culebra, el parpadeo del
  // texto y los bombillos.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _stepMs * DemoSnakePainter.pathLength),
  )..repeat();

  int get _ms => (_anim.value * _anim.duration!.inMilliseconds).round();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _play() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SetupScreen()));
  }

  void _records() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RecordsScreen()));
  }

  void _howTo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HowToScreen()));
  }

  // Enter o espacio = "echar la moneda".
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      _play();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return ArcadeScaffold(
      onKey: _onKey,
      // AnimatedBuilder redibuja la hoja en cada frame del reloj.
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => _buildCabinet(),
      ),
    );
  }

  Widget _buildCabinet() {
    final ms = _ms;
    final blinkOn = (ms ~/ 450).isEven; // prende y apaga cada 0,45 s

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildMarquee(ms ~/ 300),
          const SizedBox(height: 24),
          _buildDemo(ms ~/ _stepMs),
          const SizedBox(height: 24),
          Opacity(
            opacity: blinkOn ? 1 : 0,
            child: Text(
              'INSERTE UN BOLÍVAR',
              style: pixelText(11, neonYellow, glow: 8),
            ),
          ),
          const Spacer(),
          PixelButton(
            label: 'JUGAR',
            color: neonYellow,
            big: true,
            onTap: _play,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelButton(label: 'RÉCORDS', color: neonBlue, onTap: _records),
              const SizedBox(width: 12),
              PixelButton(label: 'CÓMO JUGAR', color: neonRed, onTap: _howTo),
            ],
          ),
          const Spacer(),
          Text('HECHO EN VENEZUELA', style: pixelText(7, Colors.white38)),
        ],
      ),
    );
  }

  // El letrero de arriba con los bombillos alrededor.
  Widget _buildMarquee(int lightsPhase) {
    return Container(
      decoration: BoxDecoration(
        color: arcadePanel,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: CustomPaint(
        painter: MarqueeLightsPainter(lightsPhase),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
          child: Column(
            children: [
              Text(
                'LA MAQUINITA DE LA BODEGA',
                style: pixelText(7, neonBlue, glow: 6),
              ),
              const SizedBox(height: 18),
              Text(
                'MAPANARE',
                style: pixelText(30, neonYellow).copyWith(
                  letterSpacing: 2,
                  shadows: [
                    // Sombra roja dura (sin difuminar) = letras "en 3D"
                    // como en los juegos viejos, más un brillo amarillo.
                    const Shadow(color: neonRed, offset: Offset(3, 3)),
                    Shadow(
                      color: neonYellow.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Rayita tricolor de cuadritos que brillan.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in const [neonYellow, neonBlue, neonRed])
                    Container(
                      width: 30,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: c,
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('SNAKE CRIOLLO', style: pixelText(9, Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  // La "pantallita" donde juega sola la culebra.
  Widget _buildDemo(int step) {
    const cell = 16.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: neonGreen.withValues(alpha: 0.7), width: 3),
        boxShadow: [
          BoxShadow(color: neonGreen.withValues(alpha: 0.25), blurRadius: 14),
        ],
      ),
      child: SizedBox(
        width: cell * DemoSnakePainter.cols,
        height: cell * DemoSnakePainter.rows,
        child: CustomPaint(painter: DemoSnakePainter(step)),
      ),
    );
  }
}
