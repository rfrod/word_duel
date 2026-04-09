import 'dart:math';

/// Gera o tabuleiro de 15 letras com frequência ponderada por idioma e tema.
abstract class LetterThemeFactory {
  static final Random _random = Random();

  // ─── Frequências base por idioma ──────────────────────────────────────────

  /// PT-BR: frequência relativa de cada letra (× 1000 para inteiro)
  static const Map<String, int> _ptBase = {
    'A': 146, 'E': 126, 'O': 107, 'S': 78, 'R': 65,
    'I': 62,  'N': 50,  'D': 50,  'M': 48, 'T': 44,
    'C': 39,  'U': 36,  'L': 33,  'P': 25, 'V': 17,
    'G': 13,  'H': 9,   'F': 10,  'B': 10, 'Q': 12,
    'Z': 5,   'J': 4,   'X': 3,   'K': 2,  'Y': 1,
    'W': 1,
  };

  /// EN: frequência relativa
  static const Map<String, int> _enBase = {
    'E': 127, 'T': 91,  'A': 82,  'O': 75, 'I': 70,
    'N': 67,  'S': 63,  'H': 61,  'R': 59, 'D': 43,
    'L': 40,  'C': 28,  'U': 28,  'M': 24, 'W': 24,
    'F': 22,  'G': 20,  'Y': 20,  'P': 19, 'B': 15,
    'V': 10,  'K': 8,   'J': 2,   'X': 2,  'Q': 1,
    'Z': 1,
  };

  /// ES: frequência relativa
  static const Map<String, int> _esBase = {
    'E': 137, 'A': 125, 'O': 87,  'S': 79, 'R': 69,
    'N': 67,  'I': 62,  'D': 59,  'L': 50, 'T': 46,
    'C': 40,  'U': 39,  'M': 32,  'P': 29, 'B': 15,
    'G': 12,  'V': 11,  'F': 9,   'H': 7,  'J': 6,
    'Z': 5,   'Y': 4,   'X': 3,   'K': 1,  'W': 1,
    'Q': 8,
  };

  // ─── Modificadores de tema ─────────────────────────────────────────────────
  // Os modificadores são somados à frequência base para o tema ativo.

  static const Map<String, Map<String, int>> _themeModifiers = {
    'food': {
      'A': 30, 'C': 20, 'H': 15, 'L': 20, 'M': 15,
      'N': 15, 'O': 20, 'R': 15, 'S': 10, 'T': 15,
    },
    'animals': {
      'A': 20, 'B': 15, 'G': 15, 'L': 15, 'N': 20,
      'O': 15, 'P': 15, 'R': 20, 'T': 15, 'U': 15,
    },
    'sports': {
      'A': 20, 'C': 15, 'E': 15, 'F': 15, 'L': 20,
      'N': 15, 'O': 20, 'P': 15, 'S': 20, 'T': 20,
    },
    'tech': {
      'A': 15, 'C': 20, 'D': 15, 'E': 20, 'I': 20,
      'N': 15, 'O': 15, 'P': 15, 'R': 20, 'T': 20,
    },
  };

  // ─── API pública ───────────────────────────────────────────────────────────

  /// Gera uma lista de [count] letras para o tabuleiro.
  static List<String> generateBoard({
    required String locale,
    required String theme,
    int count = 15,
  }) {
    final baseFreq = _baseFrequency(locale);
    final modifiers = _themeModifiers[theme] ?? {};

    // Combina frequência base + modificador de tema
    final combined = <String, int>{};
    for (final entry in baseFreq.entries) {
      combined[entry.key] =
          entry.value + (modifiers[entry.key] ?? 0);
    }

    // Constrói pool ponderado
    final pool = <String>[];
    for (final entry in combined.entries) {
      // Divide por 10 para manter pool razoável
      final weight = (entry.value / 10).ceil();
      pool.addAll(List.filled(weight, entry.key));
    }

    // Garante ao menos 3 vogais entre as primeiras letras selecionadas
    final result = <String>[];
    final vowels = _vowelsForLocale(locale);
    var vowelCount = 0;

    while (result.length < count) {
      if (vowelCount < 5 && (count - result.length) <= (5 - vowelCount)) {
        // Força vogal quando necessário para garantir jogabilidade
        final vowelPool =
            pool.where((l) => vowels.contains(l)).toList();
        result.add(vowelPool[_random.nextInt(vowelPool.length)]);
        vowelCount++;
      } else {
        final letter = pool[_random.nextInt(pool.length)];
        result.add(letter);
        if (vowels.contains(letter)) vowelCount++;
      }
    }

    result.shuffle(_random);
    return result;
  }

  /// Retorna todos os temas disponíveis.
  static List<String> get availableThemes =>
      _themeModifiers.keys.toList();

  /// Seleciona um tema aleatório para a rodada.
  static String randomTheme() {
    final themes = availableThemes;
    return themes[_random.nextInt(themes.length)];
  }

  // ─── Privado ───────────────────────────────────────────────────────────────

  static Map<String, int> _baseFrequency(String locale) {
    switch (locale) {
      case 'en':
        return _enBase;
      case 'es':
        return _esBase;
      default: // 'pt'
        return _ptBase;
    }
  }

  static Set<String> _vowelsForLocale(String locale) {
    // Todas as línguas suportadas compartilham o mesmo conjunto básico de vogais
    return {'A', 'E', 'I', 'O', 'U'};
  }
}
