import 'dart:math';

// Las 4 direcciones. Cada una sabe cuánto suma en x y en y por paso.
// Ojo: en pantalla la y crece HACIA ABAJO, por eso "up" es y = -1.
enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.dx, this.dy);

  final int dx;
  final int dy;

  Point<int> get vector => Point(dx, dy);

  bool isOpposite(Direction other) => dx == -other.dx && dy == -other.dy;
}

// En qué momento está la partida.
// won = llenaste todo el campo (¡casi imposible!).
enum GameStatus { ready, playing, gameOver, won }

// La LÓGICA del juego, sin nada de dibujo ni de Flutter.
// Esta clase solo sabe de casillas, direcciones y reglas. La pantalla
// le pregunta "¿dónde está la culebra?" y la dibuja.
class SnakeGame {
  // `random` es opcional: los tests le pasan uno fijo para que la comida
  // salga siempre en el mismo sitio y la prueba sea predecible.
  SnakeGame(this.cells, {Random? random}) : _random = random ?? Random() {
    reset();
  }

  final int cells; // casillas por lado
  final Random _random;

  late List<Point<int>> snake; // posición actual (snake[0] = cabeza)
  late List<Point<int>> previous; // posición del paso anterior (para animar)
  late Point<int> food;
  late GameStatus status;
  int score = 0; // cuántas comidas lleva esta partida

  late Direction _direction;
  // Cola de giros pendientes. Si el jugador aprieta ↑ y → muy rápido (antes
  // de que la culebra avance), guardamos los dos y los aplicamos en orden,
  // uno por paso. Sin esto, el segundo giro "borraría" al primero.
  final List<Direction> _turns = [];

  bool get isOver => status == GameStatus.gameOver || status == GameStatus.won;

  void reset() {
    final mid = cells ~/ 2;
    // En el campo pequeño empieza con 3 casillas; en los demás, con 4.
    // La cabeza siempre arranca en x = 3, mirando a la derecha.
    final length = cells <= 10 ? 3 : 4;
    snake = [for (var i = 0; i < length; i++) Point(3 - i, mid)];
    previous = List.of(snake);
    // La primera comida sale en el mismo sitio, enfrente de la culebra.
    food = Point(cells - 1 - cells ~/ 4, mid);
    status = GameStatus.ready;
    score = 0;
    _direction = Direction.right;
    _turns.clear();
  }

  // El jugador pide girar.
  void turn(Direction d) {
    if (isOver) return;

    // La primera tecla arranca la partida (menos ir hacia atrás).
    if (status == GameStatus.ready) {
      if (d.isOpposite(_direction)) return;
      _direction = d;
      status = GameStatus.playing;
      return;
    }

    // Comparamos contra el ÚLTIMO giro pedido, no contra la dirección
    // actual, para que la cola tenga sentido.
    final last = _turns.isEmpty ? _direction : _turns.last;
    if (d == last || d.isOpposite(last)) return; // no se puede dar la vuelta
    if (_turns.length < 2) _turns.add(d);
  }

  // Avanza UN paso. El game loop llama esto cada X milisegundos.
  void step() {
    if (status != GameStatus.playing) return;

    if (_turns.isNotEmpty) _direction = _turns.removeAt(0);
    final newHead = snake.first + _direction.vector;
    final eats = newHead == food;

    final hitsWall = newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= cells ||
        newHead.y >= cells;

    // ¿Se muerde a sí misma? Detalle importante: si NO come, la cola se va
    // a mover y deja libre su casilla, así que perseguirse la cola es
    // válido. Si COME, la cola se queda donde está y sí cuenta.
    final body = eats ? snake : snake.sublist(0, snake.length - 1);
    final hitsSelf = body.contains(newHead);

    if (hitsWall || hitsSelf) {
      status = GameStatus.gameOver;
      previous = List.of(snake); // se queda quieta donde chocó
      return;
    }

    previous = List.of(snake);
    if (eats) {
      // Crecer = cabeza nueva adelante SIN quitar la última casilla.
      snake = [newHead, ...snake];
      score++;
      _spawnFood();
    } else {
      // Moverse = cabeza nueva adelante + quitar la última casilla.
      snake = [newHead, ...snake.sublist(0, snake.length - 1)];
    }
  }

  // Pone la comida en una casilla libre al azar.
  void _spawnFood() {
    // Hacemos la lista de TODAS las casillas que no ocupa la culebra y
    // escogemos una. Usamos un Set para que `contains` sea rapidísimo.
    final occupied = snake.toSet();
    final free = [
      for (var x = 0; x < cells; x++)
        for (var y = 0; y < cells; y++)
          if (!occupied.contains(Point(x, y))) Point(x, y),
    ];
    if (free.isEmpty) {
      status = GameStatus.won; // llenaste el campo entero
      return;
    }
    food = free[_random.nextInt(free.length)];
  }
}
