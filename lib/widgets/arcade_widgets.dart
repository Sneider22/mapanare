import 'package:flutter/material.dart';

import '../arcade/arcade_style.dart';
import 'arcade_painters.dart';

// Piezas que comparten todas las pantallas de la maquinita.

// El "mueble" de la maquinita: fondo oscuro, rayitas de tele vieja encima
// y el contenido en una hoja fija de 360 × 640 que FittedBox agranda o
// achica para que quepa entera. Por eso nunca hay scroll.
class ArcadeScaffold extends StatelessWidget {
  const ArcadeScaffold({
    super.key,
    required this.child,
    this.onKey,
    this.focusNode,
  });

  final Widget child;
  final FocusOnKeyEventCallback? onKey; // teclado (opcional)
  final FocusNode? focusNode; // para recuperar el teclado (el juego lo usa)

  static const width = 360.0;
  static const height = 640.0;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: onKey,
      child: Scaffold(
        backgroundColor: arcadeBg,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: FittedBox(
                  child: SizedBox(width: width, height: height, child: child),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: CrtPainter())),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón de maquinita: esquinas rectas, borde negro y un "escalón" debajo.
// Al presionarlo se hunde, como un botón de verdad.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.big = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool big;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _down = false; // ¿lo están presionando ahorita?

  @override
  Widget build(BuildContext context) {
    final depth = widget.big ? 6.0 : 4.0;
    final shade = Color.lerp(widget.color, Colors.black, 0.45)!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: Transform.translate(
          offset: Offset(0, _down ? depth : 0),
          child: Container(
            padding: widget.big
                ? const EdgeInsets.symmetric(horizontal: 44, vertical: 18)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
                // Sombra dura hacia abajo = el escalón del botón.
                BoxShadow(color: shade, offset: Offset(0, _down ? 0 : depth)),
              ],
            ),
            child: Text(
              widget.label,
              style: pixelText(widget.big ? 18 : 9, arcadeBg),
            ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta seleccionable (modo, campo, comida). La elegida brilla en
// amarillo; las demás quedan apagaditas.
class ArcadeTile extends StatelessWidget {
  const ArcadeTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.label,
    required this.width,
    required this.height,
    this.icon,
    this.caption,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final double width;
  final double height;
  final Widget? icon;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final color = selected ? neonYellow : Colors.white24;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2A2150) : arcadePanel,
            border: Border.all(color: color, width: 3),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: neonYellow.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(height: 8)],
              Text(
                label,
                style: pixelText(
                  icon != null ? 7 : 10,
                  selected ? neonYellow : Colors.white70,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 6),
                Text(caption!, style: pixelText(6, Colors.white38)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
