import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/player.dart';
import '../models/room.dart';
import '../models/score.dart';

/// Camada de acesso a dados do Supabase.
/// Toda lógica de negócio fica no GameNotifier; aqui apenas I/O.
class GameRepository {
  GameRepository(this._supabase);

  final SupabaseClient _supabase;
  static const _uuid = Uuid();

  // ─── Player ───────────────────────────────────────────────────────────────

  Future<Player> getOrCreatePlayer(String userId, String username, String locale) async {
    final existing = await _supabase
        .from('players')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existing != null) return Player.fromJson(existing);

    final data = {
      'id': userId,
      'username': username,
      'locale': locale,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _supabase.from('players').insert(data);
    return Player.fromJson(data);
  }

  Future<void> updatePlayerLocale(String playerId, String locale) async {
    await _supabase
        .from('players')
        .update({'locale': locale})
        .eq('id', playerId);
  }

  // ─── Matchmaking ──────────────────────────────────────────────────────────

  Future<void> joinQueue(String playerId, String locale) async {
    // Upsert para evitar duplicata
    await _supabase.from('matchmaking_queue').upsert({
      'id': _uuid.v4(),
      'player_id': playerId,
      'locale': locale,
      'created_at': DateTime.now().toIso8601String(),
    }, onConflict: 'player_id');
  }

  Future<void> leaveQueue(String playerId) async {
    await _supabase
        .from('matchmaking_queue')
        .delete()
        .eq('player_id', playerId);
  }

  /// Busca um oponente na fila (mesmo idioma, não é o próprio jogador).
  Future<Player?> findOpponent(String playerId, String locale) async {
    final rows = await _supabase
        .from('matchmaking_queue')
        .select('player_id, players!inner(id, username, locale, total_score, created_at)')
        .eq('locale', locale)
        .neq('player_id', playerId)
        .order('created_at')
        .limit(1);

    if (rows.isEmpty) return null;
    final playerData = rows.first['players'] as Map<String, dynamic>;
    return Player.fromJson(playerData);
  }

  // ─── Room ─────────────────────────────────────────────────────────────────

  Future<Room> createRoom({
    required String playerAId,
    required String playerBId,
    required String locale,
    required String theme,
  }) async {
    final id = _uuid.v4();
    final data = {
      'id': id,
      'player_a': playerAId,
      'player_b': playerBId,
      'locale': locale,
      'theme': theme,
      'status': 'playing',
      'created_at': DateTime.now().toIso8601String(),
    };
    await _supabase.from('rooms').insert(data);
    return Room.fromJson(data);
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    await _supabase
        .from('rooms')
        .update({'status': status})
        .eq('id', roomId);
  }

  // ─── Round ────────────────────────────────────────────────────────────────

  Future<String> createRound({
    required String roomId,
    required List<String> letters,
    required String theme,
    required int betTime,
  }) async {
    final id = _uuid.v4();
    await _supabase.from('rounds').insert({
      'id': id,
      'room_id': roomId,
      'letters': letters,
      'theme': theme,
      'bet_time': betTime,
      'started_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  // ─── Score / Validação ────────────────────────────────────────────────────

  /// Envia pontuação ao servidor; a Edge Function valida a palavra antes de salvar.
  Future<Score?> submitAndValidateWord({
    required String roundId,
    required String playerId,
    required String word,
    required String locale,
    required String theme,
    required int rawPoints,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'validate-word',
        body: {
          'round_id': roundId,
          'player_id': playerId,
          'word': word,
          'locale': locale,
          'theme': theme,
          'raw_points': rawPoints,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['valid'] == true) {
          return Score.fromJson(data['score'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Score>> getRoundScores(String roundId) async {
    final rows = await _supabase
        .from('scores')
        .select()
        .eq('round_id', roundId);
    return rows.map((r) => Score.fromJson(r)).toList();
  }

  // ─── Leaderboard ──────────────────────────────────────────────────────────

  Future<List<Player>> getLeaderboard({String? locale, int limit = 50}) async {
    final List<Map<String, dynamic>> rows;

    if (locale != null) {
      rows = await _supabase
          .from('players')
          .select()
          .eq('locale', locale)
          .order('total_score', ascending: false)
          .limit(limit);
    } else {
      rows = await _supabase
          .from('players')
          .select()
          .order('total_score', ascending: false)
          .limit(limit);
    }

    return rows.map((r) => Player.fromJson(r)).toList();
  }

  // ─── Realtime Channel ─────────────────────────────────────────────────────

  RealtimeChannel subscribeToRoom({
    required String roomId,
    required void Function(Map<String, dynamic> payload) onTileSelected,
    required void Function(Map<String, dynamic> payload) onWordSubmitted,
    required void Function(Map<String, dynamic> payload) onRoundEnded,
    required void Function(Map<String, dynamic> payload) onScoreUpdated,
    required void Function(Map<String, dynamic> payload) onBetPlaced,
  }) {
    return _supabase
        .channel('room:$roomId')
        .onBroadcast(
          event: 'tile_selected',
          callback: (payload) => onTileSelected(payload),
        )
        .onBroadcast(
          event: 'word_submitted',
          callback: (payload) => onWordSubmitted(payload),
        )
        .onBroadcast(
          event: 'round_ended',
          callback: (payload) => onRoundEnded(payload),
        )
        .onBroadcast(
          event: 'score_updated',
          callback: (payload) => onScoreUpdated(payload),
        )
        .onBroadcast(
          event: 'bet_placed',
          callback: (payload) => onBetPlaced(payload),
        )
        .subscribe();
  }

  Future<void> broadcast({
    required String roomId,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    await _supabase.channel('room:$roomId').sendBroadcastMessage(
          event: event,
          payload: payload,
        );
  }

  void unsubscribeRoom(String roomId) {
    _supabase.channel('room:$roomId').unsubscribe();
  }
}
