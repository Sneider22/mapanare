import 'package:flutter/material.dart';

import 'game/records.dart';
import 'screens/home_screen.dart';

// Punto de entrada: Flutter arranca aquí y "infla" el widget raíz.
// `async` porque antes de mostrar la app leemos los récords guardados.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necesario antes de usar plugins
  await Records.load();
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
      home: const HomeScreen(),
    );
  }
}
