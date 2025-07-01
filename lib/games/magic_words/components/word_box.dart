import 'dart:ui';

import 'package:app_asd_diagnostic/games/magic_words/components/audio_button.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/magic_words.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';

class WordBox extends PositionComponent with HasGameRef<JogoFormaPalavrasGame> {
  final List<LetterBox> letterBoxes;
  final String correctWord;
  final String tip;
  late final AudioButton audioButton;
  bool isInitiallyCorrect;
  final VoidCallback onSolved;
  final VoidCallback onCorrect;
  final void Function(int wrongLetters) onWrong; // continua
  final void Function(int wrongLetters) onWrongLetterTap; // NOVO
  final bool immediateCheckMode;

  WordBox({
    required this.letterBoxes,
    required this.correctWord,
    required Vector2 audioButtonPosition,
    required String audioPath,
    required String spritePath,
    required this.tip,
    required this.onSolved,
    required this.onCorrect,
    required this.onWrong,
    required this.onWrongLetterTap,
    this.isInitiallyCorrect = false,
    this.immediateCheckMode = false,
  }) {
    // Adiciona o botão de áudio
    audioButton = AudioButton(
      position: audioButtonPosition,
      audioPath: audioPath,
      spritePath: spritePath,
    );
    add(audioButton);

    // Calcula a posição inicial das LetterBox relativa ao botão de áudio
    final initialLetterBoxX =
        audioButtonPosition.x + 70; // Ajuste de 70 pixels ao lado
    final initialLetterBoxY = audioButtonPosition.y;

    // Posiciona as LetterBox corretamente ao lado do botão
    for (int i = 0; i < letterBoxes.length; i++) {
      letterBoxes[i].position =
          Vector2(initialLetterBoxX + (i * 60), initialLetterBoxY);
      add(letterBoxes[i]);
    }
  }

  AudioPlayer? _currentFx;

  Future<void> _playFx(String file) async {
    if (_currentFx != null) {
      await _currentFx!.stop(); // pára o que estiver tocando
    }
    final p = await FlameAudio.play(file, volume: 0.5); // assets/audio/<file>
    _currentFx = p;
    p.onPlayerComplete.listen((_) {
      // libera referência
      if (_currentFx == p) _currentFx = null;
    });
  }

  Future<void> checkLetterAt(int index) async {
    final box = letterBoxes[index];
    final letter = box.currentLetter;
    if (letter == null) return;

    final correct = correctWord[index].toLowerCase() == letter.toLowerCase();
    if (correct) {
      _playFx('words_adventure/success.wav');
      // troca sprite e trava
      await box.setLetter(
        letter,
        await Sprite.load('words_adventure/letters/${letter}_correct.png'),
      );
      box.isLocked = true;
      _popLetterAnimation(index);
      gameRef.checkPalavrasCompletas();

      // **Novo**: se agora todas as letras estão travadas, resolve a palavra
      if (letterBoxes.every((b) => b.isLocked) && !isInitiallyCorrect) {
        isInitiallyCorrect = true;
        onSolved();
        waveAnimation();
      }
    } else {
      // erro na letra única
      _playFx('words_adventure/error.wav');
      await box.setLetter(
        letter,
        await Sprite.load('words_adventure/letters/${letter}_wrong.png'),
      );
      _shakeLetterAnimation(index);
      Future.delayed(const Duration(milliseconds: 500), () {
        box.reset();
      });
      onWrongLetterTap(1);
    }
  }

  void _popLetterAnimation(int index) async {
    final box = letterBoxes[index];
    const offset = 5.0;
    const step = 50;
    // fazendo uma mini onda de 1 ciclo
    box.position.add(Vector2(0, -offset));
    await Future.delayed(const Duration(milliseconds: step));
    box.position.add(Vector2(0, offset));
  }

  void _shakeLetterAnimation(int index) async {
    final box = letterBoxes[index];
    const d = 5.0, t = 50;
    for (var i = 0; i < 3; i++) {
      box.position.add(Vector2(d, 0));
      await Future.delayed(const Duration(milliseconds: t));
      box.position.add(Vector2(-2 * d, 0));
      await Future.delayed(const Duration(milliseconds: t));
      box.position.add(Vector2(d, 0));
      await Future.delayed(const Duration(milliseconds: t));
    }
  }

  Future<bool> checkWord() async {
    if (isInitiallyCorrect) {
      return true;
    }
    if (!areAllFilled()) {
      return false;
    }

    String constructedWord =
        letterBoxes.map((box) => box.currentLetter ?? '').join();
    print(constructedWord);
    print(correctWord);

    if (constructedWord.length == correctWord.length) {
      if (constructedWord.toLowerCase() == correctWord.toLowerCase() &&
          !isInitiallyCorrect) {
        onSolved();
        // Palavras são iguais, atualiza os sprites para a versão correta
        for (var box in letterBoxes) {
          await box.setLetter(
              box.currentLetter!,
              await Sprite.load(
                  'words_adventure/letters/${box.currentLetter}_correct.png'));
          box.isLocked = true; // Trava a letra no LetterBox
        }
        _playFx('words_adventure/success.wav');
        isInitiallyCorrect = true;
        waveAnimation(); // Animação de onda para indicar acerto
        onCorrect();
        return true;
      } else {
        // Palavras têm o mesmo comprimento, mas são diferentes
        for (int i = 0; i < letterBoxes.length; i++) {
          await letterBoxes[i].setLetter(
              letterBoxes[i].currentLetter!,
              await Sprite.load(
                  'words_adventure/letters/${letterBoxes[i].currentLetter}_wrong.png'));
        }
        _playFx('words_adventure/error.wav');
        _shakeAnimation(); // Animação de shake para indicar erro
        // Redefine os LetterBox após a animação de erro
        Future.delayed(const Duration(milliseconds: 500), () {
          for (var box in letterBoxes) {
            box.reset();
          }
        });
      }
    }
    return false;
  }

  void waveAnimation() async {
    const double waveHeight = 5.0; // Diminui a amplitude do movimento de onda
    const int waveDuration = 50;

    for (int i = 0; i < 3; i++) {
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, -waveHeight));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, waveHeight * 2));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, -waveHeight));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
    }
  }

  void _shakeAnimation() async {
    const double shakeDistance = 5.0;
    const int shakeDuration = 50;

    for (int i = 0; i < 3; i++) {
      for (var box in letterBoxes) {
        box.position.add(Vector2(shakeDistance, 0));
      }
      await Future.delayed(const Duration(milliseconds: shakeDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(-shakeDistance * 2, 0));
      }
      await Future.delayed(const Duration(milliseconds: shakeDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(shakeDistance, 0));
      }
      await Future.delayed(const Duration(milliseconds: shakeDuration));
    }
  }

  bool isLetterInCorrectPosition(int index, String letter) {
    return correctWord[index] == letter;
  }

  bool areAllFilled() {
    return letterBoxes.every((box) => box.currentLetter != null);
  }

  void resetWord() {
    for (var box in letterBoxes) {
      box.reset();
    }
  }
}
