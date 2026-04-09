import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/player.dart';
import '../../../data/repositories/game_repository.dart';
import '../../game/notifiers/game_notifier.dart';

class RankingState {
  final List<Player> players;
  final bool isLoading;
  final String? errorMessage;
  final String? localeFilter;

  const RankingState({
    this.players = const [],
    this.isLoading = false,
    this.errorMessage,
    this.localeFilter,
  });

  RankingState copyWith({
    List<Player>? players,
    bool? isLoading,
    String? errorMessage,
    String? localeFilter,
    bool clearError = false,
  }) =>
      RankingState(
        players: players ?? this.players,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        localeFilter: localeFilter ?? this.localeFilter,
      );
}

class RankingNotifier extends StateNotifier<RankingState> {
  RankingNotifier(this._ref) : super(const RankingState()) {
    load();
  }

  final Ref _ref;
  GameRepository get _repo => _ref.read(gameRepositoryProvider);

  Future<void> load({String? locale}) async {
    state = state.copyWith(isLoading: true, clearError: true, localeFilter: locale);
    try {
      final players = await _repo.getLeaderboard(locale: locale);
      state = state.copyWith(players: players, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => load(locale: state.localeFilter);
}

final rankingNotifierProvider =
    StateNotifierProvider.autoDispose<RankingNotifier, RankingState>(
  (ref) => RankingNotifier(ref),
);
