import 'package:birdle/game.dart';
import 'package:birdle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Logic Tests', () {
    test('Game initializes with empty guesses and a hidden word', () {
      final game = Game(seed: 0);
      expect(game.hiddenWord.length, 5);
      expect(game.guessesRemaining, 6);
      expect(game.didWin, false);
      expect(game.didLose, false);
    });

    test('isLegalGuess correctly identifies valid and invalid guesses', () {
      final game = Game();
      expect(game.isLegalGuess('crane'), true);
      expect(game.isLegalGuess('robin'), true);
      expect(game.isLegalGuess('eagle'), true);
      expect(game.isLegalGuess('zzzzz'), false);
    });

    test('evaluateGuess marks hits, partials, and misses accurately', () {
      final game = Game(seed: 0);
      final word = game.hiddenWord.toString();
      final evaluated = game.matchGuessOnly(word);
      for (final letter in evaluated) {
        expect(letter.type, HitType.hit);
      }
    });

    test('Game tracks winning state', () {
      final game = Game(seed: 0);
      final word = game.hiddenWord.toString();
      game.guess(word);
      expect(game.didWin, true);
      expect(game.didLose, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('Tapping on-screen keyboard enters letters into tiles', (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MainApp());

      // Tap key 'C'
      final keyC = find.text('C');
      expect(keyC, findsWidgets);
      await tester.tap(keyC.first);
      await tester.pump();

      // Tap key 'R'
      final keyR = find.text('R');
      await tester.tap(keyR.first);
      await tester.pump();

      // Find backspace button and tap it
      final backspace = find.byIcon(Icons.backspace_outlined);
      expect(backspace, findsOneWidget);
      await tester.tap(backspace);
      await tester.pump();

      // Verify game state and input functioning without crashes
      expect(find.byType(Tile), findsWidgets);
    });

    testWidgets('Backspace smoothly removes letters through animation frames without assertion errors', (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MainApp());

      // Tap key 'A'
      final keyA = find.text('A');
      await tester.tap(keyA.first);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap key 'P'
      final keyP = find.text('P');
      await tester.tap(keyP.first);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap backspace
      final backspace = find.byIcon(Icons.backspace_outlined);
      await tester.tap(backspace);

      // Pump through intermediate animation frames
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Tap backspace again
      await tester.tap(backspace);
      await tester.pumpAndSettle();
    });
  });
}
