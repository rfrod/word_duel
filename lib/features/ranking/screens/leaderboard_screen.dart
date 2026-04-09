import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/player.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../notifiers/ranking_notifier.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rankingNotifierProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (locale) =>
                ref.read(rankingNotifierProvider.notifier).load(locale: locale),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Global')),
              const PopupMenuItem(value: 'pt', child: Text('Português')),
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'es', child: Text('Español')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(rankingNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(state.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(rankingNotifierProvider.notifier).refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : state.players.isEmpty
                  ? const Center(
                      child: Text('Nenhum dado de ranking ainda.'),
                    )
                  : _LeaderboardList(
                      players: state.players,
                      currentPlayerId: currentPlayer?.id,
                    ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.players,
    this.currentPlayerId,
  });

  final List<Player> players;
  final String? currentPlayerId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = players[index];
        final isMe = player.id == currentPlayerId;
        final rank = index + 1;

        return _LeaderboardTile(
          rank: rank,
          player: player,
          isCurrentPlayer: isMe,
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.player,
    required this.isCurrentPlayer,
  });

  final int rank;
  final Player player;
  final bool isCurrentPlayer;

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // ouro
      case 2:
        return const Color(0xFFC0C0C0); // prata
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return AppColors.onSurfaceMuted;
    }
  }

  IconData _rankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(rank);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer ? AppColors.primary : Colors.transparent,
          width: isCurrentPlayer ? 2 : 0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: SizedBox(
          width: 40,
          child: rank <= 3
              ? Icon(_rankIcon(rank), color: rankColor, size: 28)
              : Text(
                  '#$rank',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
        title: Text(
          player.username,
          style: TextStyle(
            fontWeight: isCurrentPlayer ? FontWeight.w700 : FontWeight.w500,
            color: isCurrentPlayer ? AppColors.primary : AppColors.onBackground,
          ),
        ),
        subtitle: Text(
          player.locale.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceMuted,
          ),
        ),
        trailing: Text(
          '${player.totalScore} pts',
          style: TextStyle(
            color: rankColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
