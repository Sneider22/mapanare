// Las comidas que se puede comer la culebra. Igual que BoardSize,
// cada opción guarda el nombre que se muestra en el menú.
enum Food {
  arepa('Arepa'),
  mango('Mango'),
  hamburguesa('Hamburguesa'),
  pollo('Pollo'),
  hayaca('Hayaca'),
  tequeno('Tequeño');

  const Food(this.label);

  final String label;
}
