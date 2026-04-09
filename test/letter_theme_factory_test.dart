import 'package:flutter_test/flutter_test.dart';
import 'package:word_duel/l10n/letter_theme_factory.dart';

void main() {
  group('LetterThemeFactory', () {
    test('gera exatamente 15 letras', () {
      final board = LetterThemeFactory.generateBoard(
        locale: 'pt',
        theme: 'food',
      );
      expect(board.length, 15);
    });

    test('gera letras válidas (apenas A-Z)', () {
      for (final locale in ['pt', 'en', 'es']) {
        for (final theme in LetterThemeFactory.availableThemes) {
          final board = LetterThemeFactory.generateBoard(
            locale: locale,
            theme: theme,
          );
          for (final letter in board) {
            expect(
              RegExp(r'^[A-Z]$').hasMatch(letter),
              isTrue,
              reason: 'Letra inválida "$letter" gerada para $locale/$theme',
            );
          }
        }
      }
    });

    test('garante ao menos 4 vogais no tabuleiro', () {
      const vowels = {'A', 'E', 'I', 'O', 'U'};
      // Testa várias gerações para verificar consistência estatística
      for (var i = 0; i < 20; i++) {
        final board = LetterThemeFactory.generateBoard(
          locale: 'pt',
          theme: 'food',
        );
        final vowelCount =
            board.where((l) => vowels.contains(l)).length;
        expect(vowelCount, greaterThanOrEqualTo(4));
      }
    });

    test('randomTheme retorna tema válido', () {
      final themes = LetterThemeFactory.availableThemes;
      for (var i = 0; i < 10; i++) {
        expect(themes, contains(LetterThemeFactory.randomTheme()));
      }
    });
  });
}
