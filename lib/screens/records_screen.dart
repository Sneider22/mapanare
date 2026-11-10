import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../arcade/arcade_style.dart';
import '../game/board_size.dart';
import '../game/game_mode.dart';
import '../game/records.dart';
import '../widgets/arcade_widgets.dart';

// PANTALLA DE RÉCORDS: el mejor puntaje de cada modo y cada campo.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // BORRAR pide confirmación: el primer toque lo "arma", el segundo borra.
  bool _confirming = false;

  Future<void> _onClear() async {
    if (!_confirming) {
      setState(() => _confirming = true);
      return;
    }
    await Records.clear();
    if (mounted) setState(() => _confirming = false);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
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
            const SizedBox(height: 22),
            _buildTop(),
            const SizedBox(height: 22),
            for (final m in GameMode.values) ...[
              _ModeTable(mode: m),
              const SizedBox(height: 14),
            ],
            const Spacer(),
            PixelButton(
              label: _confirming ? '¿SEGURO? TOCA OTRA VEZ' : 'BORRAR RÉCORDS',
              color: _confirming ? neonRed : Colors.white38,
              onTap: _onClear,
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
        Text('RÉCORDS', style: pixelText(10, neonYellow, glow: 6)),
      ],
    );
  }

  // El récord máximo en grande, como en la pantalla de una maquinita.
  Widget _buildTop() {
    final top = Records.top;
    return Column(
      children: [
        Text('EL MÁS ARRECHO', style: pixelText(8, neonBlue, glow: 4)),
        const SizedBox(height: 12),
        Text(
          top.toString().padLeft(3, '0'),
          style: pixelText(40, neonYellow).copyWith(
            shadows: [
              const Shadow(color: neonRed, offset: Offset(3, 3)),
              Shadow(color: neonYellow.withValues(alpha: 0.5), blurRadius: 16),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          top == 0 ? 'TODAVÍA NADIE HA JUGADO' : 'PUNTOS',
          style: pixelText(7, Colors.white38),
        ),
      ],
    );
  }
}

// Una cajita por modo: PEQUEÑO ..... 012, etc.
class _ModeTable extends StatelessWidget {
  const _ModeTable({required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final color = mode == GameMode.clasico ? neonGreen : neonRed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: arcadePanel,
        border: Border.all(color: color.withValues(alpha: 0.7), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('> ${mode.label}', style: pixelText(9, color, glow: 4)),
          const SizedBox(height: 10),
          for (final s in BoardSize.values) _row(s),
        ],
      ),
    );
  }

  Widget _row(BoardSize size) {
    final best = Records.best(mode, size);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(size.label.toUpperCase(), style: pixelText(8, Colors.white70)),
          // Los puntitos que llenan el espacio, como en las tablas viejas.
          Expanded(
            child: Text(
              ' ${'.' * 40}',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: pixelText(8, Colors.white24),
            ),
          ),
          Text(
            ' ${best.toString().padLeft(3, '0')}',
            style: pixelText(9, best > 0 ? neonYellow : Colors.white38),
          ),
        ],
      ),
    );
  }
}
