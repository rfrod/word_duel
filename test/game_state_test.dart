import 'package:flutter_test/flutter_test.dart';
import 'package:word_duel/data/models/game_state.dart';
import 'package:word_duel/data/models/player.dart';

void main() {
  group('GameState', () {
    final mockPlayer = Player(
      id: 'p1',
      username: 'Alice',
      locale: 'pt',
      createdAt: DateTime(2024),
    );
    final mockOpponent = Player(
      id: 'p2',
      username: 'Bob',
      locale: 'pt',
      createdAt: DateTime(2024),
    );

    test('estado inicial tem fase waiting', () {
      expect(GameState.initial().phase, GamePhase.waiting);
    });

    test('currentWord monta palavra corretamente a partir dos índices', () {
      final state = GameState(
        boardLetters: const ['C', 'A', 'S', 'A', 'X'],
        selectedIndices: const [0, 1, 2, 1], // C-A-S-A
      );
      expect(state.currentWord, 'CASA');
    });

    test('myScore retorna 0 quando placar vazio', () {
      final state = GameState(currentPlayer: mockPlayer);
      expect(state.myScore, 0);
    });

    test('myScore retorna pontuação acumulada', () {
      final state = GameState(
        currentPlayer: mockPlayer,
        scores: {'p1': 15, 'p2': 10},
      );
      expect(state.myScore, 15);
      expect(state.opponentScore, 0); // sem opponentPlayer definido
    });

    test('bothBetsPlaced é false quando apenas um apostou', () {
      final state = GameState(selectedBet: BetOption.fast);
      expect(state.bothBetsPlaced, isFalse);
    });

    test('bothBetsPlaced é true quando ambos apostaram', () {
      final state = GameState(
        selectedBet: BetOption.fast,
        opponentBet: BetOption.slow,
      );
      expect(state.bothBetsPlaced, isTrue);
    });

    test('isLastRound é true quando currentRound == totalRounds', () {
      const state = GameState(currentRound: 5, totalRounds: 5);
      expect(state.isLastRound, isTrue);
    });

    test('copyWith preserva valores não alterados', () {
      final state = GameState(
        currentPlayer: mockPlayer,
        opponentPlayer: mockOpponent,
        currentRound: 3,
      );
      final next = state.copyWith(phase: GamePhase.betting);
      expect(next.currentPlayer, mockPlayer);
      expect(next.currentRound, 3);
      expect(next.phase, GamePhase.betting);
    });

    test('BetOption tem multiplicadores corretos', () {
      expect(BetOption.fast.multiplier, 2.0);
      expect(BetOption.normal.multiplier, 1.0);
      expect(BetOption.slow.multiplier, 0.5);
    });
  });
}
