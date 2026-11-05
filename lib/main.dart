import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';

// Punto de entrada: Flutter arranca aquí y "infla" el widget raíz.
void main() {
  runApp(const MapanareApp());
}

class MapanareApp extends StatelessWidget {
  const MapanareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapanare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
