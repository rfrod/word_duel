import 'package:equatable/equatable.dart';

class Round extends Equatable {
  final String id;
  final String roomId;
  final List<String> letters; // 15 letras
  final String theme;
  final int betTime; // 5, 10 ou 20 segundos
  final DateTime startedAt;

  const Round({
    required this.id,
    required this.roomId,
    required this.letters,
    required this.theme,
    required this.betTime,
    required this.startedAt,
  });

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        letters: List<String>.from(json['letters'] as List),
        theme: json['theme'] as String,
        betTime: json['bet_time'] as int,
        startedAt: DateTime.parse(json['started_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'letters': letters,
        'theme': theme,
        'bet_time': betTime,
        'started_at': startedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, roomId, letters, theme, betTime];
}
