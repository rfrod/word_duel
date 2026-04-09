import 'package:equatable/equatable.dart';
import 'player.dart';
import 'round.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum GamePhase {
  /// Aguardando oponente (matchmaking)
  waiting,

  /// Cada jogador escolhe sua aposta de tempo
  betting,

  /// Jogadores formam palavras simultaneamente
  playing,

  /// Resultado da rodada sendo exibido
  roundEnd,

  /// Fim do jogo completo
  gameEnd,
}

enum BetOption {
  fast(10, 2.0),
  normal(15, 1.0),
  slow(20, 0.5);

  const BetOption(this.seconds, this.multiplier);

  final int seconds;
  final double multiplier;
}

enum WordFeedback { none, valid, invalid }

// ─── State ────────────────────────────────────────────────────────────────────

class GameState extends Equatable {
  final GamePhase phase;

  /// 15 letras do tabuleiro atual
  final List<String> boardLetters;

  /// Índices das letras selecionadas pelo jogador local
  final List<int> selectedIndices;

  /// Índices das letras que o oponente selecionou (via Realtime)
  final List<int> opponentSelectedIndices;

  /// Aposta confirmada pelo jogador local
  final BetOption? selectedBet;

  /// Aposta confirmada pelo oponente
  final BetOption? opponentBet;

  /// Pontuação acumulada: playerId → pontos
  final Map<String, int> scores;

  /// Rodada atual (1-based)
  final int currentRound;

  /// Total de rodadas na partida
  final int totalRounds;

  final String? roomId;
  final String? currentRoundId;
  final String theme;
  final String locale;

  /// Jogador local
  final Player? currentPlayer;

  /// Oponente (humano ou IA)
  final Player? opponentPlayer;

  final bool isAiOpponent;

  /// Validação de palavra em progresso
  final bool isValidating;

  /// Feedback da última palavra submetida
  final WordFeedback wordFeedback;
  final int? lastWordPoints;

  const GameState({
    this.phase = GamePhase.waiting,
    this.boardLetters = const [],
    this.selectedIndices = const [],
    this.opponentSelectedIndices = const [],
    this.selectedBet,
    this.opponentBet,
    this.scores = const {},
    this.currentRound = 1,
    this.totalRounds = 5,
    this.roomId,
    this.currentRoundId,
    this.theme = 'food',
    this.locale = 'pt',
    this.currentPlayer,
    this.opponentPlayer,
    this.isAiOpponent = false,
    this.isValidating = false,
    this.wordFeedback = WordFeedback.none,
    this.lastWordPoints,
  });

  factory GameState.initial() => const GameState();

  String get currentWord => selectedIndices.map((i) => boardLetters[i]).join();

  int get myScore => scores[currentPlayer?.id] ?? 0;
  int get opponentScore => scores[opponentPlayer?.id] ?? 0;

  bool get isLastRound => currentRound >= totalRounds;
  bool get bothBetsPlaced => selectedBet != null && opponentBet != null;

  Round? get currentRoundModel => currentRoundId != null
      ? Round(
          id: currentRoundId!,
          roomId: roomId ?? '',
          letters: boardLetters,
          theme: theme,
          betTime: selectedBet?.seconds ?? 10,
          startedAt: DateTime.now(),
        )
      : null;

  GameState copyWith({
    GamePhase? phase,
    List<String>? boardLetters,
    List<int>? selectedIndices,
    List<int>? opponentSelectedIndices,
    BetOption? selectedBet,
    BetOption? opponentBet,
    Map<String, int>? scores,
    int? currentRound,
    int? totalRounds,
    String? roomId,
    String? currentRoundId,
    String? theme,
    String? locale,
    Player? currentPlayer,
    Player? opponentPlayer,
    bool? isAiOpponent,
    bool? isValidating,
    WordFeedback? wordFeedback,
    int? lastWordPoints,
    int? cumulativeRoundCount,
    bool clearBets = false,
    bool clearWordFeedback = false,
  }) =>
      GameState(
        phase: phase ?? this.phase,
        boardLetters: boardLetters ?? this.boardLetters,
        selectedIndices: selectedIndices ?? this.selectedIndices,
        opponentSelectedIndices:
            opponentSelectedIndices ?? this.opponentSelectedIndices,
        selectedBet: clearBets ? null : (selectedBet ?? this.selectedBet),
        opponentBet: clearBets ? null : (opponentBet ?? this.opponentBet),
        scores: scores ?? this.scores,
        currentRound: currentRound ?? this.currentRound,
        totalRounds: totalRounds ?? this.totalRounds,
        roomId: roomId ?? this.roomId,
        currentRoundId: currentRoundId ?? this.currentRoundId,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
        currentPlayer: currentPlayer ?? this.currentPlayer,
        opponentPlayer: opponentPlayer ?? this.opponentPlayer,
        isAiOpponent: isAiOpponent ?? this.isAiOpponent,
        isValidating: isValidating ?? this.isValidating,
        wordFeedback:
            clearWordFeedback ? WordFeedback.none : (wordFeedback ?? this.wordFeedback),
        lastWordPoints: clearWordFeedback ? null : (lastWordPoints ?? this.lastWordPoints),
      );

  @override
  List<Object?> get props => [
        phase,
        boardLetters,
        selectedIndices,
        opponentSelectedIndices,
        selectedBet,
        opponentBet,
        scores,
        currentRound,
        totalRounds,
        roomId,
        currentRoundId,
        theme,
        locale,
        currentPlayer,
        opponentPlayer,
        isAiOpponent,
        isValidating,
        wordFeedback,
        lastWordPoints,
      ];
}
