import 'dart:math';

import 'package:flutter/material.dart';

import '../game/board_size.dart';
import '../game/food.dart';
import '../widgets/food_painter.dart';
import '../widgets/menu_painters.dart';
import 'game_screen.dart';

const _cream = Color(0xFFF7EBD3);
const _gold = Color(0xFFE9A93B);
const _brown = Color(0xFF3E2A14);

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

// SingleTickerProviderStateMixin le da a la pantalla un "reloj" (ticker)
// que avisa en cada frame: lo necesita el AnimationController.
class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  BoardSize _size = BoardSize.mediano;
  Food _food = Food.arepa;

  // Va de 0 a 1 en 2 segundos y vuelve a empezar, para siempre.
  // Con ese valor movemos la onda de la culebra y el "respirar" del botón.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose(); // siempre apagar los controllers al salir
    super.dispose();
  }

  void _play() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(size: _size, food: _food)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack: capas una encima de otra. Abajo el fondo, arriba el contenido.
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: FieldBackgroundPainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 8),
                      _buildTitle(),
                      const SizedBox(height: 28),
                      _buildPanel(),
                      const SizedBox(height: 32),
                      _buildPlayButton(),
                      const SizedBox(height: 20),
                      const Text(
                        'Teclado: WASD o flechas  ·  Teléfono: desliza',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // AnimatedBuilder reconstruye SOLO esto en cada frame de la animación,
    // no toda la pantalla.
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => SizedBox(
        width: 300,
        height: 110,
        child: CustomPaint(
          painter: LogoSnakePainter(phase: _anim.value, food: _food),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'MAPANARE',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: _cream,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Rayita tricolor: amarillo, azul y rojo.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in const [
              Color(0xFFFFCC00),
              Color(0xFF00247D),
              Color(0xFFCF142B),
            ])
              Container(
                width: 30,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Snale criollo',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // Panel tipo "vidrio": blanco casi transparente con borde suave.
  Widget _buildPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const _SectionTitle('TAMAÑO DEL CAMPO'),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final s in BoardSize.values)
                _OptionTile(
                  selected: s == _size,
                  onTap: () => setState(() => _size = s),
                  icon: CustomPaint(
                    painter: GridIconPainter((s.cells / 2.5).round()),
                  ),
                  label: s.label,
                  caption: '${s.cells}×${s.cells}',
                ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('¿QUÉ TE VAS A COMER?'),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in Food.values)
                _OptionTile(
                  selected: f == _food,
                  onTap: () => setState(() => _food = f),
                  icon: CustomPaint(painter: FoodIconPainter(f)),
                  label: f.label,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        // sin() sube y baja suavecito: el botón "respira" un 3%.
        final scale = 1 + 0.03 * sin(_anim.value * 2 * pi);
        return Transform.scale(scale: scale, child: child);
      },
      // `child` se construye una sola vez y se reutiliza en cada frame.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(colors: [Color(0xFFF7D98B), _gold]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: _play,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: _brown, size: 32),
                  SizedBox(width: 6),
                  Text(
                    'JUGAR',
                    style: TextStyle(
                      color: _brown,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// Una tarjetica seleccionable, la misma para tamaños y para comidas:
// ícono arriba, nombre abajo y (opcional) un texto chiquito extra.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.label,
    this.caption,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final String? caption; // el ? significa que puede ser null (opcional)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // AnimatedScale + AnimatedContainer: al seleccionar, la tarjeta crece
      // un poquito y cambia de color con una transición suave.
      child: AnimatedScale(
        scale: selected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? _cream.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _gold : Colors.white.withValues(alpha: 0.12),
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              SizedBox(width: 44, height: 44, child: icon),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? _brown : Colors.white,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: TextStyle(
                    color: selected ? _brown.withValues(alpha: 0.6) : Colors.white54,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
