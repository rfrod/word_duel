import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ad_manager.dart';
import '../../../core/utils/revenue_cat_manager.dart';
import '../notifiers/game_notifier.dart';

/// Exibe o resultado final da partida.
/// Anúncio intersticial é exibido aqui (nunca durante a partida) após um delay,
/// respeitando as regras de compliance da App Store.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    // Exibe o anúncio após 1s (dá tempo ao usuário ver o resultado)
    _adTimer = Timer(const Duration(seconds: 1), _maybeShowAd);
  }

  Future<void> _maybeShowAd() async {
    if (kIsWeb) return;
    await AdManager.instance.recordGameEnd(
      isPro: RevenueCatManager.instance.isPro,
    );
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameNotifierProvider);
    final myScore = game.myScore;
    final opponentScore = game.opponentScore;
    final iWon = myScore > opponentScore;
    final isDraw = myScore == opponentScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone resultado
              _ResultIcon(iWon: iWon, isDraw: isDraw),
              const SizedBox(height: 24),

              // Título
              Text(
                isDraw
                    ? 'Empate!'
                    : iWon
                        ? 'Você venceu!'
                        : 'Você perdeu!',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Resultado final',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Placar final
              _ScoreCard(
                myName: game.currentPlayer?.username ?? 'Você',
                opponentName: game.opponentPlayer?.username ?? 'Oponente',
                myScore: myScore,
                opponentScore: opponentScore,
                isAiOpponent: game.isAiOpponent,
              ),
              const SizedBox(height: 40),

              // Botões
              ElevatedButton(
                onPressed: () async {
                  await ref.read(gameNotifierProvider.notifier).resetGame();
                  if (context.mounted) context.go('/game');
                },
                child: const Text('Jogar novamente'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(gameNotifierProvider.notifier).resetGame();
                  if (context.mounted) context.go('/');
                },
                child: const Text('Menu principal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon({required this.iWon, required this.isDraw});
  final bool iWon;
  final bool isDraw;

  @override
  Widget build(BuildContext context) {
    if (isDraw) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.handshake_rounded,
          size: 56,
          color: AppColors.warning,
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: iWon
            ? AppColors.success.withOpacity(0.15)
            : AppColors.error.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iWon ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
        size: 56,
        color: iWon ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.myName,
    required this.opponentName,
    required this.myScore,
    required this.opponentScore,
    required this.isAiOpponent,
  });

  final String myName;
  final String opponentName;
  final int myScore;
  final int opponentScore;
  final bool isAiOpponent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PlayerScore(
            name: myName,
            score: myScore,
            color: AppColors.primary,
          ),
          Container(
            height: 60,
            width: 1,
            color: AppColors.surfaceVariant,
          ),
          _PlayerScore(
            name: isAiOpponent ? '$opponentName 🤖' : opponentName,
            score: opponentScore,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  const _PlayerScore({
    required this.name,
    required this.score,
    required this.color,
  });

  final String name;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 40,
          ),
        ),
        Text(
          'pontos',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
