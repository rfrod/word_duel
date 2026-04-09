import 'package:equatable/equatable.dart';

enum RoomStatus { waiting, playing, finished }

class Room extends Equatable {
  final String id;
  final String playerAId;
  final String? playerBId;
  final String locale;
  final String theme;
  final RoomStatus status;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.playerAId,
    this.playerBId,
    required this.locale,
    required this.theme,
    required this.status,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        playerAId: json['player_a'] as String,
        playerBId: json['player_b'] as String?,
        locale: json['locale'] as String,
        theme: json['theme'] as String,
        status: RoomStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'player_a': playerAId,
        'player_b': playerBId,
        'locale': locale,
        'theme': theme,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isFull => playerBId != null;

  @override
  List<Object?> get props => [id, playerAId, playerBId, locale, theme, status];
}
