import 'package:flutter_test/flutter_test.dart';
import 'package:mapanare/howto/scenes.dart';

void main() {
  test('los videos de Cómo jugar hacen lo que dicen', () {
    final [basics, anis, blackout] = howToScenes;

    // Solo el video básico termina en choque (en su último capítulo).
    final crash = basics.frames.indexWhere((f) => f.view.crashed);
    expect(basics.frames[crash].chapter, basics.chapters.length - 1);
    expect(basics.frames.last.score, 7);
    expect(anis.frames.any((f) => f.view.crashed), isFalse);
    expect(blackout.frames.any((f) => f.view.crashed), isFalse);

    // Anís: 3 puntos + 2 comidas, y en algún momento los controles al revés.
    expect(anis.frames.last.score, 5);
    expect(anis.frames.any((f) => f.view.inverted), isTrue);

    // Apagón: hay parpadeo, oscuridad y se come las 3 comidas.
    expect(
      blackout.frames.any((f) => f.banner == 'LA LUZ ESTÁ FALLANDO...'),
      isTrue,
    );
    expect(blackout.frames.any((f) => f.view.dark), isTrue);
    expect(blackout.frames.last.score, 3);
  });
}
