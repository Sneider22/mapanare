import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/board_size.dart';
import '../game/food.dart';
import '../game/snake_game.dart';
import '../widgets/board_painter.dart';
import '../widgets/food_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.size, required this.food});

  final BoardSize size;
  final Food food;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // Récords por tamaño de campo. `static` = pertenece a la CLASE, no a una
  // pantalla en particular: sobrevive cuando sales al menú y vuelves a
  // entrar (pero se pierde al cerrar la app; eso lo arreglamos después).
  static final Map<BoardSize, int> _records = {};

  int get _best => _records[widget.size] ?? 0; // ?? = "si es null, usa 0"
  bool _newRecord = false;

  static const _headerHeight = 56.0;
  static const _frame = 12.0;

  // Cada cuánto avanza la culebra una casilla. Menos = más rápido.
  // (Aquí entrará el modo dificultad más adelante.)
  static const _stepTime = Duration(milliseconds: 140);

  late final SnakeGame _game = SnakeGame(widget.size.cells);

  // ===== GAME LOOP =====
  // Un Ticker llama a _onTick en CADA frame de la pantalla (~60 por
  // segundo) y nos dice cuánto tiempo pasó desde que arrancó.
  late final _ticker = createTicker(_onTick);
  Duration _lastStep = Duration.zero; // cuándo fue el último paso
  double _progress = 1; // qué tanto va del paso actual (0 a 1)

  // Para que el teclado le llegue a esta pantalla.
  final _focus = FocusNode();

  // Para detectar el deslizar del dedo.
  Offset _drag = Offset.zero;

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
    if (_game.status != GameStatus.playing) {
      // Si no estamos jugando, el reloj del juego no corre.
      _lastStep = elapsed;
      return;
    }

    // ¿Ya pasó el tiempo de un paso? Entonces avanzamos. Es un `while`
    // por si el teléfono se trabó un momento y debemos varios pasos.
    while (elapsed - _lastStep >= _stepTime) {
      _lastStep += _stepTime;
      _game.step();
      if (_game.isOver) {
        _saveRecord();
        break;
      }
    }

    // Cuánto va del paso actual, para el movimiento suave.
    setState(() {
      _progress = (elapsed - _lastStep).inMicroseconds /
          _stepTime.inMicroseconds;
    });
  }

  // Al terminar la partida: si superaste el récord, se actualiza solo.
  void _saveRecord() {
    if (_game.score > _best) {
      _records[widget.size] = _game.score;
      _newRecord = true;
    }
  }

  void _turn(Direction d) => setState(() => _game.turn(d));

  void _restart() {
    setState(() {
      _game.reset();
      _progress = 1;
      _newRecord = false;
    });
    _focus.requestFocus(); // que el teclado siga funcionando
  }

  // ===== TECLADO =====
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    // `switch` como expresión: devuelve una dirección o null.
    final dir = switch (key) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD =>
        Direction.right,
      _ => null, // cualquier otra tecla
    };

    if (dir != null) {
      _turn(dir);
      return KeyEventResult.handled;
    }
    // Enter o espacio para jugar otra vez después de chocar.
    if (_game.isOver &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)) {
      _restart();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ===== DESLIZAR (TÁCTIL) =====
  // Vamos sumando cuánto se movió el dedo. Cuando pasa de 24 píxeles,
  // vemos si se movió más en horizontal o en vertical y giramos.
  // Luego reiniciamos la suma para poder encadenar giros sin soltar.
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

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF24451A),
        // El GestureDetector cubre TODA la pantalla: puedes deslizar en
        // cualquier lado, no solo encima del tablero.
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => _drag = Offset.zero,
          onPanUpdate: _onPanUpdate,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final side = min(
                      min(box.maxWidth, 640.0),
                      box.maxHeight - _headerHeight,
                    );
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: side,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            Container(
                              color: const Color(0xFF4E8A2E),
                              padding: const EdgeInsets.all(_frame),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: BoardPainter(
                                          cells: _game.cells,
                                          snake: _game.snake,
                                          previous: _game.previous,
                                          progress: _progress.clamp(0, 1),
                                          food: widget.food,
                                          foodPos: _game.food,
                                        ),
                                      ),
                                    ),
                                    ..._buildOverlay(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Lo que se muestra ENCIMA del tablero según el estado de la partida.
  List<Widget> _buildOverlay() {
    switch (_game.status) {
      case GameStatus.ready:
        return [
          Align(
            alignment: const Alignment(0, 0.75),
            child: _Pill(
              text: 'Usa las flechas, WASD o desliza para empezar',
            ),
          ),
        ];
      case GameStatus.playing:
        return [];
      case GameStatus.gameOver:
      case GameStatus.won:
        final won = _game.status == GameStatus.won;
        return [
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    won ? '¡Llenaste el campo!' : '¡Chocaste!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF7EBD3),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cuánto comiste: ícono de la comida + número.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CustomPaint(
                          painter: FoodIconPainter(widget.food),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_game.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (_newRecord) ...[
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, color: Color(0xFFFFC107)),
                        SizedBox(width: 6),
                        Text(
                          '¡Nuevo récord!',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Otra vez'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE9A93B),
                      foregroundColor: const Color(0xFF3E2A14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
    }
  }

  Widget _buildHeader() {
    const numberStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
    return Container(
      height: _headerHeight,
      color: const Color(0xFF3F7425),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: FoodIconPainter(widget.food)),
          ),
          const SizedBox(width: 8),
          Text('${_game.score}', style: numberStyle),
          const SizedBox(width: 28),
          const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 28),
          const SizedBox(width: 6),
          Text('$_best', style: numberStyle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Salir al menú',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// Cartelito redondeado semitransparente.
class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
