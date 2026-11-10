// Los modos de juego. Clásico = solo comida. Criollo = con sorpresas
// (anís y apagón). Las sorpresas las programamos en un paso siguiente.
enum GameMode {
  clasico('CLÁSICO', 'SOLO COMIDA'),
  criollo('CRIOLLO', 'CON SORPRESAS');

  const GameMode(this.label, this.caption);

  final String label;
  final String caption;
}
