import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../arcade/arcade_style.dart';
import '../game/board_size.dart';
import '../game/food.dart';
import '../game/game_mode.dart';
import '../game/records.dart';
import '../game/snake_game.dart';
import '../widgets/arcade_widgets.dart';
import '../widgets/pixel_board.dart';
import '../widgets/pixel_foods.dart';
import '../widgets/pixel_sprite.dart';

// LA PARTIDA, con look de maquinita. Las reglas están en snake_game.dart;
// esta pantalla solo maneja el tiempo, los controles y el dibujo.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.size,
    required this.food,
    this.mode = GameMode.clasico,
    this.game,
  });

  final BoardSize size;
  final Food food;
  final GameMode mode; // Criollo = con anís y apagones

  // Solo para tests: una partida ya armada (ej. para las capturas del
  // README). En el juego normal es null y se crea una nueva.
  @visibleForTesting
  final SnakeGame? game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const _boardSide = 320.0; // el tablero ocupa todo el ancho útil

  // Cada cuánto avanza la culebra una casilla. Menos = más rápido.
  static const _stepTime = Duration(milliseconds: 140);

  late final SnakeGame _game =
      widget.game ??
      SnakeGame(widget.size.cells, criollo: widget.mode == GameMode.criollo);
  Sprite get _sprite => foodSprites[widget.food]!;

  // El récord de ESTA combinación modo + campo (lib/game/records.dart).
  int get _best => Records.best(widget.mode, widget.size);
  bool _newRecord = false;

  // ===== GAME LOOP =====
  // El Ticker nos llama en cada frame (~60 por segundo). Cuando junta
  // 140 ms, la culebra avanza un paso. En pixel art el movimiento va de
  // casilla en casilla, como en las maquinitas de antes.
  late final Ticker _ticker = createTicker(_onTick);
  Duration _now = Duration.zero;
  Duration _lastStep = Duration.zero;

  final _focus = FocusNode(); // para que el teclado le llegue al juego
  Offset _drag = Offset.zero; // para detectar el deslizar del dedo

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _now = elapsed;
    if (_game.status != GameStatus.playing) {
      _lastStep = elapsed; // si no estamos jugando, el reloj no corre
    }
    // `while` por si el teléfono se trabó un momento y debemos varios pasos.
    while (elapsed - _lastStep >= _stepTime) {
      _lastStep += _stepTime;
      _game.step();
      if (_game.isOver) {
        _newRecord = Records.submit(widget.mode, widget.size, _game.score);
        break;
      }
    }
    // Redibujamos siempre: así funcionan también los textos que parpadean.
    setState(() {});
  }

  void _turn(Direction d) => _game.turn(d);

  void _restart() {
    setState(() {
      _game.reset();
      _newRecord = false;
    });
    _focus.requestFocus(); // que el teclado siga funcionando
  }

  // ===== TECLADO =====
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    final dir = switch (key) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
      LogicalKeyboardKey.arrowRight ||
      LogicalKeyboardKey.keyD => Direction.right,
      _ => null,
    };

    if (dir != null) {
      _turn(dir);
      return KeyEventResult.handled;
    }
    if (_game.isOver &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)) {
      _restart();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ===== DESLIZAR (TÁCTIL) =====
  // Sumamos cuánto se movió el dedo; al pasar de 24 px vemos si fue más
  // horizontal o vertical y giramos. Se pueden encadenar giros sin soltar.
  void _onPanUpdate(DragUpdateDetails d) {
    _drag += d.delta;
    if (_drag.distance < 24) return;
    final Direction dir;
    if (_drag.dx.abs() > _drag.dy.abs()) {
      dir = _drag.dx > 0 ? Direction.right : Direction.left;
    } else {
      dir = _drag.dy > 0 ? Direction.down : Direction.up;
    }
    _turn(dir);
    _drag = Offset.zero;
  }

  bool _blink(int ms) => (_now.inMilliseconds ~/ ms).isEven;

  @override
  Widget build(BuildContext context) {
    return ArcadeScaffold(
      onKey: _onKey,
      focusNode: _focus,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => _drag = Offset.zero,
        onPanUpdate: _onPanUpdate,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 10),
              Text(
                '${widget.mode.label} · ${widget.size.label.toUpperCase()}',
                style: pixelText(7, Colors.white38),
              ),
              const SizedBox(height: 14),
              _buildBoard(),
              const SizedBox(height: 22),
              _buildHint(),
              const Spacer(),
              Text('ESC: SALIR', style: pixelText(6, Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }

  // Arriba: volver, puntos de la partida y récord.
  Widget _buildTopBar() {
    return Row(
      children: [
        PixelButton(
          label: '<',
          color: neonBlue,
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        SizedBox(
          width: 22,
          height: 22,
          child: CustomPaint(painter: SpritePainter(_sprite)),
        ),
        const SizedBox(width: 8),
        Text(_pad(_game.score), style: pixelText(14, neonYellow, glow: 6)),
        const SizedBox(width: 22),
        Text('TOP', style: pixelText(7, neonBlue, glow: 4)),
        const SizedBox(width: 8),
        Text(
          _pad(_game.score > _best ? _game.score : _best),
          style: pixelText(14, Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    final crashed = _game.status == GameStatus.gameOver;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (crashed ? neonRed : neonGreen).withValues(alpha: 0.8),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (crashed ? neonRed : neonGreen).withValues(alpha: 0.25),
            blurRadius: 14,
          ),
        ],
      ),
      child: SizedBox(
        width: _boardSide - 6,
        height: _boardSide - 6,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: PixelBoardPainter(
                  BoardView(
                    cols: _game.cells,
                    rows: _game.cells,
                    snake: _game.snake,
                    food: _game.status == GameStatus.won ? null : _game.food,
                    foodSprite: _sprite,
                    // Cuando al anís le queda poquito, parpadea: "¡apúrate!".
                    anis: _game.anisLeft < 15 && !_blink(150)
                        ? null
                        : _game.anis,
                    crashed: crashed,
                    inverted: _game.inverted,
                    // Mientras las luces fallan, el campo se apaga y prende.
                    dark:
                        !_game.isOver &&
                        (_game.dark ||
                            (_game.flickering && _game.flickerLeft.isOdd)),
                  ),
                ),
              ),
            ),
            if (_game.isOver) Positioned.fill(child: _buildGameOver()),
          ],
        ),
      ),
    );
  }

  // Debajo del tablero: cómo empezar, o los puntos mientras juegas.
  Widget _buildHint() {
    if (_game.status == GameStatus.ready) {
      return Opacity(
        opacity: _blink(450) ? 1 : 0,
        child: Column(
          children: [
            Text('FLECHAS O W A S D', style: pixelText(8, neonYellow, glow: 6)),
            const SizedBox(height: 8),
            Text(
              'EN EL TELÉFONO, DESLIZA',
              style: pixelText(7, Colors.white54),
            ),
          ],
        ),
      );
    }
    if (_game.isOver) return const SizedBox.shrink();

    // Mientras juegas: avisos de las sorpresas del modo Criollo.
    // (Se escribe con if simples a propósito: una versión con un "record"
    // que podía ser null fallaba en la web publicada por un problema del
    // compilador de producción.)
    if (_game.inverted) {
      return _notice(
        'CONTROLES AL REVÉS ${_secondsLeft(_game.invertedLeft)}',
        invertedPurple,
      );
    }
    if (_game.flickering) return _notice('LA LUZ ESTÁ FALLANDO...', neonYellow);
    if (_game.dark) return _notice('SE FUE LA LUZ', neonYellow);
    if (_game.anis != null) return _notice('¡APARECIÓ UN ANÍS! +3', neonBlue);
    return const SizedBox.shrink();
  }

  Widget _notice(String text, Color color) =>
      Text(text, style: pixelText(9, color, glow: 6));

  // Pasos que faltan → segundos, redondeando hacia arriba.
  String _secondsLeft(int steps) =>
      (steps * _stepTime.inMilliseconds / 1000).ceil().toString();

  // El cartel encima del tablero cuando se acaba la partida.
  Widget _buildGameOver() {
    final won = _game.status == GameStatus.won;
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            won ? '¡CAMPO LLENO!' : '¡CHOCASTE!',
            style: pixelText(18, won ? neonYellow : neonRed, glow: 10),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(painter: SpritePainter(_sprite)),
              ),
              const SizedBox(width: 12),
              Text(_pad(_game.score), style: pixelText(22, Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 14,
            child: _newRecord
                ? Opacity(
                    opacity: _blink(300) ? 1 : 0.25,
                    child: Text(
                      '¡NUEVO RÉCORD!',
                      style: pixelText(9, neonYellow, glow: 6),
                    ),
                  )
                : Text(
                    'RÉCORD ${_pad(_best)}',
                    style: pixelText(8, Colors.white38),
                  ),
          ),
          const SizedBox(height: 24),
          PixelButton(label: 'OTRA VEZ', color: neonYellow, onTap: _restart),
          const SizedBox(height: 14),
          PixelButton(
            label: 'MENÚ',
            color: neonBlue,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(3, '0');
}
