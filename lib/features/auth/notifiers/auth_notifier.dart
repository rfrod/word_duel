import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/player.dart';
import '../../../data/repositories/game_repository.dart';
import '../../game/notifiers/game_notifier.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final User? supabaseUser;
  final Player? player;
  final bool isLoading;
  final String? errorMessage;

  /// true quando o cadastro foi feito mas o e-mail ainda não foi confirmado
  final bool awaitingEmailConfirmation;

  const AuthState({
    this.supabaseUser,
    this.player,
    this.isLoading = false,
    this.errorMessage,
    this.awaitingEmailConfirmation = false,
  });

  bool get isAuthenticated => supabaseUser != null;

  AuthState copyWith({
    User? supabaseUser,
    Player? player,
    bool? isLoading,
    String? errorMessage,
    bool? awaitingEmailConfirmation,
    bool clearError = false,
  }) =>
      AuthState(
        supabaseUser: supabaseUser ?? this.supabaseUser,
        player: player ?? this.player,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        awaitingEmailConfirmation:
            awaitingEmailConfirmation ?? this.awaitingEmailConfirmation,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  final Ref _ref;
  SupabaseClient get _supabase => _ref.read(supabaseClientProvider);
  GameRepository get _repo => _ref.read(gameRepositoryProvider);

  void _init() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _loadPlayer(session.user);
    }

    _supabase.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        _loadPlayer(user);
      } else {
        state = const AuthState();
      }
    });
  }

  Future<void> _loadPlayer(User user) async {
    state = state.copyWith(supabaseUser: user, isLoading: true);
    try {
      final player = await _repo.getOrCreatePlayer(
        user.id,
        user.email?.split('@').first ?? 'jogador',
        'pt',
      );
      state = state.copyWith(player: player, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      // Supabase retorna session == null quando confirmação de e-mail está ativa
      if (response.session == null) {
        state = state.copyWith(
          isLoading: false,
          awaitingEmailConfirmation: true,
        );
      }
      // Se session != null, onAuthStateChange já vai tratar o login
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _supabase.auth.signInAnonymously();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState();
  }

  Future<void> updateUsername(String username) async {
    final player = state.player;
    if (player == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _supabase
          .from('players')
          .update({'username': username})
          .eq('id', player.id);
      state = state.copyWith(
        player: player.copyWith(username: username),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateLocale(String locale) async {
    final player = state.player;
    if (player == null) return;

    await _repo.updatePlayerLocale(player.id, locale);
    state = state.copyWith(player: player.copyWith(locale: locale));
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

final currentPlayerProvider = Provider<Player?>((ref) {
  return ref.watch(authNotifierProvider).player;
});
