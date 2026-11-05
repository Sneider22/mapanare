// Los 3 tamaños de tablero. Un `enum` "mejorado" de Dart puede tener datos:
// cada opción guarda su nombre para mostrar y cuántas casillas tiene por lado.
// Menos casillas = menos espacio = más difícil.
enum BoardSize {
  pequeno('Pequeño', 10),
  mediano('Mediano', 15),
  grande('Grande', 20);

  const BoardSize(this.label, this.cells);

  final String label;
  final int cells;
}
