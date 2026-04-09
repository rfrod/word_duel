import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String username;
  final String locale;
  final int totalScore;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.username,
    required this.locale,
    this.totalScore = 0,
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        username: json['username'] as String,
        locale: json['locale'] as String? ?? 'pt',
        totalScore: json['total_score'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'locale': locale,
        'total_score': totalScore,
        'created_at': createdAt.toIso8601String(),
      };

  Player copyWith({
    String? id,
    String? username,
    String? locale,
    int? totalScore,
    DateTime? createdAt,
  }) =>
      Player(
        id: id ?? this.id,
        username: username ?? this.username,
        locale: locale ?? this.locale,
        totalScore: totalScore ?? this.totalScore,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Jogador IA local para fallback de matchmaking
  static Player get aiPlayer => Player(
        id: 'ai_opponent',
        username: 'Duelo Bot',
        locale: 'pt',
        totalScore: 0,
        createdAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [id, username, locale, totalScore];
}
