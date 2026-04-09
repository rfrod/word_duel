import 'package:equatable/equatable.dart';

class Score extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final String word;
  final int points;
  final DateTime? validatedAt;

  const Score({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.word,
    required this.points,
    this.validatedAt,
  });

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        id: json['id'] as String,
        roundId: json['round_id'] as String,
        playerId: json['player_id'] as String,
        word: json['word'] as String,
        points: json['points'] as int,
        validatedAt: json['validated_at'] != null
            ? DateTime.parse(json['validated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'round_id': roundId,
        'player_id': playerId,
        'word': word,
        'points': points,
        'validated_at': validatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, roundId, playerId, word, points];
}
