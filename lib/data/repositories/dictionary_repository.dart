import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Repositório de dicionário offline usando Hive.
///
/// - Na primeira execução por idioma, carrega o `.txt` de assets e persiste no Hive.
/// - Nas execuções seguintes, lê direto do Hive (sem I/O de assets).
/// - Para a IA local, expõe [findWords] que retorna palavras válidas com as letras do tabuleiro.
class DictionaryRepository {
  static const String _boxPrefix = 'dict_';
  static const String _loadedKey = '__loaded__';

  final Map<String, Box<bool>> _boxes = {};

  // ─── Inicialização ─────────────────────────────────────────────────────────

  /// Deve ser chamado no main antes de usar o repositório.
  Future<void> initialize() async {
    await Hive.initFlutter();
  }

  /// Carrega o dicionário do idioma no Hive se ainda não foi carregado.
  Future<void> loadLocale(String locale) async {
    final boxName = '$_boxPrefix$locale';

    if (!_boxes.containsKey(locale)) {
      _boxes[locale] = await Hive.openBox<bool>(boxName);
    }

    final box = _boxes[locale]!;

    // Verifica se já foi carregado anteriormente
    if (box.get(_loadedKey) == true) return;

    await _loadFromAssets(locale, box);
  }

  Future<void> _loadFromAssets(String locale, Box<bool> box) async {
    try {
      final content =
          await rootBundle.loadString('assets/dictionaries/$locale.txt');
      final words = content
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length >= 2)
          .toList();

      // Batch write para performance
      final map = <String, bool>{};
      for (final word in words) {
        map[word] = true;
      }
      map[_loadedKey] = true;
      await box.putAll(map);
    } catch (_) {
      // Arquivo de dicionário ausente: marca como carregado para não tentar novamente
      await box.put(_loadedKey, true);
    }
  }

  // ─── Validação ─────────────────────────────────────────────────────────────

  /// Retorna `true` se a palavra existe no dicionário local do idioma.
  bool isValidWord(String word, String locale) {
    final box = _boxes[locale];
    if (box == null) return false;
    return box.get(word.toUpperCase()) == true;
  }

  // ─── IA local (fallback de matchmaking) ───────────────────────────────────

  /// Encontra palavras válidas que podem ser formadas com as [letters] disponíveis.
  /// Retorna lista ordenada por comprimento decrescente (a IA prioriza palavras longas).
  List<String> findWords(List<String> letters, String locale, {int maxResults = 5}) {
    final box = _boxes[locale];
    if (box == null) return [];

    final available = letters.map((l) => l.toUpperCase()).toList();
    final results = <String>[];

    for (final key in box.keys) {
      if (key == _loadedKey) continue;
      final word = key as String;
      if (word.length < 3) continue;
      if (_canFormWord(word, available)) {
        results.add(word);
        if (results.length >= maxResults * 3) break; // limita iteração
      }
    }

    results.sort((a, b) => b.length.compareTo(a.length));
    return results.take(maxResults).toList();
  }

  bool _canFormWord(String word, List<String> available) {
    final pool = List<String>.from(available);
    for (final char in word.split('')) {
      final idx = pool.indexOf(char);
      if (idx == -1) return false;
      pool.removeAt(idx);
    }
    return true;
  }

  // ─── Limpeza ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
  }
}
