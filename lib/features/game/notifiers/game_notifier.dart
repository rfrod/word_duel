import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/game_state.dart';
import '../../../data/models/player.dart';
import '../../../core/utils/ad_manager.dart';
import '../../../core/utils/revenue_cat_manager.dart';
import '../../../data/models/score.dart';
import '../../../data/repositories/dictionary_repository.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../l10n/letter_theme_factory.dart';
import 'timer_notifier.dart';

// ─── Providers de infraestrutura ──────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(supabaseClientProvider));
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
});

// ─── GameNotifier ─────────────────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this._ref) : super(GameState.initial());

  final Ref _ref;
  GameRepository get _repo => _ref.read(gameRepositoryProvider);
  DictionaryRepository get _dict => _ref.read(dictionaryRepositoryProvider);
  TimerNotifier get _timer => _ref.read(timerNotifierProvider.notifier);

  Timer? _matchmakingTimer;
  Timer? _aiThinkTimer;
  Timer? _wordFeedbackTimer;
  RealtimeChannel? _channel;

  static const int _totalRounds = 5;
  static const int _matchmakingTimeoutSeconds = 10;

  // ─── Iniciar partida ───────────────────────────────────────────────────────

  /// Ponto de entrada: inicia matchmaking para o jogador.
  Future<void> startMatchmaking(Player player) async {
    state = GameState.initial().copyWith(
      phase: GamePhase.waiting,
      currentPlayer: player,
      locale: player.locale,
    );

    await _dict.loadLocale(player.locale);
    await _repo.joinQueue(player.id, player.locale);

    // Tenta encontrar oponente a cada 2 segundos
    _matchmakingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _tryMatch(player),
    );

    // Timeout: cai para IA se não achar oponente em 10s
    Timer(const Duration(seconds: _matchmakingTimeoutSeconds), () {
      if (state.phase == GamePhase.waiting) {
        _matchmakingTimer?.cancel();
        _startWithAI(player);
      }
    });
  }

  Future<void> _tryMatch(Player player) async {
    final opponent = await _repo.findOpponent(player.id, player.locale);
    if (opponent == null) return;

    _matchmakingTimer?.cancel();
    await _repo.leaveQueue(player.id);

    final theme = LetterThemeFactory.randomTheme();
    final room = await _repo.createRoom(
      playerAId: player.id,
      playerBId: opponent.id,
      locale: player.locale,
      theme: theme,
    );

    state = state.copyWith(
      opponentPlayer: opponent,
      roomId: room.id,
      theme: theme,
    );

    _subscribeToRoom(room.id);
    _startBettingPhase();
  }

  void _startWithAI(Player player) async {
    await _repo.leaveQueue(player.id);
    final theme = LetterThemeFactory.randomTheme();

    state = state.copyWith(
      phase: GamePhase.betting,
      opponentPlayer: Player.aiPlayer,
      isAiOpponent: true,
      theme: theme,
    );
  }

  // ─── Subscrição Realtime ───────────────────────────────────────────────────

  void _subscribeToRoom(String roomId) {
    _channel = _repo.subscribeToRoom(
      roomId: roomId,
      onTileSelected: _handleOpponentTileSelected,
      onWordSubmitted: _handleOpponentWordSubmitted,
      onRoundEnded: _handleRoundEnded,
      onScoreUpdated: _handleScoreUpdated,
      onBetPlaced: _handleOpponentBetPlaced,
    );
  }

  void _handleOpponentTileSelected(Map<String, dynamic> payload) {
    final indices = List<int>.from(payload['indices'] as List? ?? []);
    state = state.copyWith(opponentSelectedIndices: indices);
  }

  void _handleOpponentWordSubmitted(Map<String, dynamic> payload) {
    // Apenas registra; o servidor valida e retorna via score_updated
  }

  void _handleRoundEnded(Map<String, dynamic> payload) {
    final newScores = Map<String, int>.from(
      (payload['scores'] as Map? ?? {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
    );
    state = state.copyWith(
      phase: GamePhase.roundEnd,
      scores: newScores,
    );
  }

  void _handleScoreUpdated(Map<String, dynamic> payload) {
    final playerId = payload['player_id'] as String;
    final points = payload['total_score'] as int;
    final newScores = Map<String, int>.from(state.scores);
    newScores[playerId] = points;
    state = state.copyWith(scores: newScores);
  }

  void _handleOpponentBetPlaced(Map<String, dynamic> payload) {
    final seconds = payload['seconds'] as int;
    final bet = BetOption.values.firstWhere(
      (b) => b.seconds == seconds,
      orElse: () => BetOption.normal,
    );
    state = state.copyWith(opponentBet: bet);
    _checkBothBetsPlaced();
  }

  // ─── Fase de Aposta ───────────────────────────────────────────────────────

  void _startBettingPhase() {
    state = state.copyWith(
      phase: GamePhase.betting,
      clearBets: true,
      selectedIndices: [],
      opponentSelectedIndices: [],
    );
  }

  void placeBet(BetOption bet) {
    if (state.phase != GamePhase.betting) return;

    state = state.copyWith(selectedBet: bet);

    // Notifica oponente humano
    if (!state.isAiOpponent && state.roomId != null) {
      _repo.broadcast(
        roomId: state.roomId!,
        event: 'bet_placed',
        payload: {
          'player_id': state.currentPlayer?.id,
          'seconds': bet.seconds,
        },
      );
    }

    if (state.isAiOpponent) {
      // IA escolhe aposta aleatória após breve delay
      Future.delayed(const Duration(milliseconds: 800), () {
        final aiBet = BetOption.values[Random().nextInt(BetOption.values.length)];
        state = state.copyWith(opponentBet: aiBet);
        _checkBothBetsPlaced();
      });
    } else {
      _checkBothBetsPlaced();
    }
  }

  void _checkBothBetsPlaced() {
    if (!state.bothBetsPlaced) return;

    // Cada jogador usa seu próprio tempo apostado.
    // O timer exibido é o do jogador local; o multiplicador de pontos
    // também é o da aposta do jogador local.
    _startPlayingPhase(state.selectedBet!.seconds);
  }

  // ─── Fase de Jogo ─────────────────────────────────────────────────────────

  Future<void> _startPlayingPhase(int timerSeconds) async {
    final letters = LetterThemeFactory.generateBoard(
      locale: state.locale,
      theme: state.theme,
    );

    String? roundId;
    if (!state.isAiOpponent && state.roomId != null) {
      roundId = await _repo.createRound(
        roomId: state.roomId!,
        letters: letters,
        theme: state.theme,
        betTime: timerSeconds,
      );
    }

    state = state.copyWith(
      phase: GamePhase.playing,
      boardLetters: letters,
      selectedIndices: [],
      opponentSelectedIndices: [],
      currentRoundId: roundId,
      clearWordFeedback: true,
    );

    _timer.start(timerSeconds, onExpired: _onTimerExpired);

    if (state.isAiOpponent) {
      _scheduleAiMove();
    }
  }

  // ─── Seleção de letras ────────────────────────────────────────────────────

  void toggleTile(int index) {
    if (state.phase != GamePhase.playing) return;

    final selected = List<int>.from(state.selectedIndices);

    if (selected.contains(index)) {
      // Deseleciona do final (mantém ordem)
      selected.remove(index);
    } else if (!selected.contains(index)) {
      selected.add(index);
    }

    state = state.copyWith(selectedIndices: selected);

    // Broadcast para oponente humano
    if (!state.isAiOpponent && state.roomId != null) {
      _repo.broadcast(
        roomId: state.roomId!,
        event: 'tile_selected',
        payload: {
          'player_id': state.currentPlayer?.id,
          'indices': selected,
        },
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(
      selectedIndices: [],
      clearWordFeedback: true,
    );
  }

  // ─── Submissão de palavra ─────────────────────────────────────────────────

  Future<void> submitWord() async {
    if (state.phase != GamePhase.playing) return;
    if (state.isValidating) return;
    if (state.currentWord.length < 2) return;

    final word = state.currentWord;
    state = state.copyWith(isValidating: true);

    // 1. Validação local (offline)
    final localValid = _dict.isValidWord(word, state.locale);

    if (!localValid) {
      _showWordFeedback(valid: false);
      return;
    }

    // 2. Calcula pontos brutos (comprimento × multiplicador da aposta)
    final multiplier = state.selectedBet?.multiplier ?? 1.0;
    final rawPoints = (word.length * multiplier).round();

    // 3. Validação no servidor (para jogos online)
    Score? score;
    if (!state.isAiOpponent && state.currentRoundId != null) {
      score = await _repo.submitAndValidateWord(
        roundId: state.currentRoundId!,
        playerId: state.currentPlayer!.id,
        word: word,
        locale: state.locale,
        theme: state.theme,
        rawPoints: rawPoints,
      );
    }

    final finalPoints = score?.points ?? rawPoints;
    final isValid = state.isAiOpponent ? localValid : (score != null);

    if (isValid) {
      final newScores = Map<String, int>.from(state.scores);
      final playerId = state.currentPlayer?.id ?? 'local';
      newScores[playerId] = (newScores[playerId] ?? 0) + finalPoints;
      state = state.copyWith(
        scores: newScores,
        selectedIndices: [],
        isValidating: false,
      );
      _showWordFeedback(valid: true, points: finalPoints);

      // Broadcast para oponente humano
      if (!state.isAiOpponent && state.roomId != null) {
        _repo.broadcast(
          roomId: state.roomId!,
          event: 'word_submitted',
          payload: {
            'player_id': state.currentPlayer?.id,
            'word': word,
            'points': finalPoints,
          },
        );
      }
    } else {
      state = state.copyWith(isValidating: false);
      _showWordFeedback(valid: false);
    }
  }

  void _showWordFeedback({required bool valid, int? points}) {
    _wordFeedbackTimer?.cancel();
    state = state.copyWith(
      wordFeedback: valid ? WordFeedback.valid : WordFeedback.invalid,
      lastWordPoints: points,
      isValidating: false,
    );
    _wordFeedbackTimer = Timer(const Duration(seconds: 2), () {
      state = state.copyWith(clearWordFeedback: true);
    });
  }

  // ─── Timer expirado ───────────────────────────────────────────────────────

  void _onTimerExpired() {
    if (state.isAiOpponent) {
      _endRoundLocally();
    }
    // Em partidas online o round_ended vem do servidor via Realtime
  }

  void _endRoundLocally() {
    if (state.isLastRound) {
      state = state.copyWith(phase: GamePhase.gameEnd);
    } else {
      state = state.copyWith(
        phase: GamePhase.roundEnd,
        currentRound: state.currentRound + 1,
      );
    }
  }

  // ─── Próxima rodada ───────────────────────────────────────────────────────

  void proceedToNextRound() {
    if (state.phase != GamePhase.roundEnd) return;

    if (state.isLastRound) {
      state = state.copyWith(phase: GamePhase.gameEnd);
    } else {
      _startBettingPhase();
    }
  }

  // ─── IA local ─────────────────────────────────────────────────────────────

  void _scheduleAiMove() {
    _aiThinkTimer?.cancel();
    final thinkTime = Duration(
      milliseconds: 1000 + Random().nextInt(3000),
    );

    _aiThinkTimer = Timer(thinkTime, () {
      if (state.phase != GamePhase.playing) return;

      final words = _dict.findWords(state.boardLetters, state.locale, maxResults: 3);
      if (words.isEmpty) return;

      final word = words.first;
      final multiplier = state.opponentBet?.multiplier ?? 1.0;
      final points = (word.length * multiplier).round();

      final newScores = Map<String, int>.from(state.scores);
      final opponentId = state.opponentPlayer?.id ?? 'ai_opponent';
      newScores[opponentId] = (newScores[opponentId] ?? 0) + points;

      // Simula as letras selecionadas pela IA
      final aiIndices = <int>[];
      final available = List<String>.from(state.boardLetters);
      for (final char in word.split('')) {
        final idx = available.indexOf(char);
        if (idx != -1) {
          aiIndices.add(idx);
          available[idx] = '';
        }
      }

      state = state.copyWith(
        scores: newScores,
        opponentSelectedIndices: aiIndices,
      );

      // Reseta seleção da IA após breve exibição
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          state = state.copyWith(opponentSelectedIndices: []);
        }
      });
    });
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Jogador desiste — registra a partida para contagem de anúncios e reseta.
  Future<void> forfeit() async {
    if (!kIsWeb) {
      await AdManager.instance.recordGameEnd(
        isPro: RevenueCatManager.instance.isPro,
      );
    }
    await resetGame();
  }

  Future<void> resetGame() async {
    _matchmakingTimer?.cancel();
    _aiThinkTimer?.cancel();
    _wordFeedbackTimer?.cancel();
    _timer.reset();

    if (state.roomId != null) {
      await _repo.updateRoomStatus(state.roomId!, 'finished');
      _repo.unsubscribeRoom(state.roomId!);
    }

    state = GameState.initial();
  }

  @override
  void dispose() {
    _matchmakingTimer?.cancel();
    _aiThinkTimer?.cancel();
    _wordFeedbackTimer?.cancel();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final gameNotifierProvider =
    StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) => GameNotifier(ref),
);
