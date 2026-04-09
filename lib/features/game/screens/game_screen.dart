import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/game_state.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../notifiers/game_notifier.dart';
import '../notifiers/timer_notifier.dart';
import '../widgets/bet_selector.dart';
import '../widgets/tile_grid.dart';
import '../widgets/timer_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = ref.read(currentPlayerProvider);
      if (player != null) {
        ref.read(gameNotifierProvider.notifier).startMatchmaking(player);
      }
    });
  }

  Future<bool> _confirmForfeit(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Desistir da partida?'),
            content: const Text(
              'Você perderá a rodada atual. Tem certeza?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continuar jogando'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Desistir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameNotifierProvider);

    // Navega para ResultScreen quando o jogo acabar
    ref.listen<GameState>(gameNotifierProvider, (prev, next) {
      if (next.phase == GamePhase.gameEnd && prev?.phase != GamePhase.gameEnd) {
        context.pushReplacement('/result');
      }
    });

    return WillPopScope(
      onWillPop: () async {
        final confirmed = await _confirmForfeit(context);
        if (confirmed) {
          await ref.read(gameNotifierProvider.notifier).forfeit();
        }
        return confirmed;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: game.phase != GamePhase.waiting
            ? AppBar(
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: const Icon(Icons.flag_outlined, color: AppColors.error),
                  tooltip: 'Desistir',
                  onPressed: () async {
                    final confirmed = await _confirmForfeit(context);
                    if (confirmed && context.mounted) {
                      await ref.read(gameNotifierProvider.notifier).forfeit();
                      context.go('/');
                    }
                  },
                ),
                title: Text(
                  'Rodada ${game.currentRound}/${game.totalRounds}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                centerTitle: true,
                actions: [
                  if (game.isAiOpponent)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Chip(
                        label: Text('🤖 IA', style: TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              )
            : null,
        body: SafeArea(
          child: _buildBody(game),
        ),
      ),
    );
  }

  Widget _buildBody(GameState game) {
    return switch (game.phase) {
      GamePhase.waiting => _WaitingView(locale: game.locale),
      GamePhase.betting => _BettingView(game: game),
      GamePhase.playing => _PlayingView(game: game),
      GamePhase.roundEnd => _RoundEndView(game: game),
      GamePhase.gameEnd => const SizedBox.shrink(), // navegado em listener
    };
  }
}

// ─── Waiting ──────────────────────────────────────────────────────────────────

class _WaitingView extends StatelessWidget {
  const _WaitingView({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Aguardando oponente…',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Idioma: $locale',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Betting ──────────────────────────────────────────────────────────────────

class _BettingView extends ConsumerWidget {
  const _BettingView({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScorePill(
                label: game.currentPlayer?.username ?? 'Você',
                score: game.myScore,
                isLocal: true,
              ),
              Column(
                children: [
                  Text(
                    'Rodada ${game.currentRound}/${game.totalRounds}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  _ThemeChip(theme: game.theme),
                ],
              ),
              _ScorePill(
                label: game.opponentPlayer?.username ?? 'Oponente',
                score: game.opponentScore,
                isLocal: false,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Escolha sua aposta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            game.isAiOpponent ? 'Jogando contra IA' : 'Oponente está escolhendo…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          BetSelector(
            selectedBet: game.selectedBet,
            onBetSelected: notifier.placeBet,
            isConfirmed: game.selectedBet != null,
          ),
          const Spacer(),
          if (game.selectedBet != null)
            _WaitingForOpponentBet(opponentBetPlaced: game.opponentBet != null),
        ],
      ),
    );
  }
}

class _WaitingForOpponentBet extends StatelessWidget {
  const _WaitingForOpponentBet({required this.opponentBetPlaced});
  final bool opponentBetPlaced;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!opponentBetPlaced) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Aguardando oponente…'),
        ] else ...[
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 6),
          const Text('Oponente apostou!'),
        ],
      ],
    );
  }
}

// ─── Playing ──────────────────────────────────────────────────────────────────

class _PlayingView extends ConsumerWidget {
  const _PlayingView({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header com placar e timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScorePill(
                label: game.currentPlayer?.username ?? 'Você',
                score: game.myScore,
                isLocal: true,
              ),
              const TimerWidget(size: 72),
              _ScorePill(
                label: game.opponentPlayer?.username ?? 'Oponente',
                score: game.opponentScore,
                isLocal: false,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ThemeChip(theme: game.theme),
          const SizedBox(height: 16),

          // Tabuleiro
          TileGrid(
            letters: game.boardLetters,
            selectedIndices: game.selectedIndices,
            opponentIndices: game.opponentSelectedIndices,
            onTileTap: notifier.toggleTile,
          ),
          const SizedBox(height: 16),

          // Palavra atual
          _WordDisplay(
            word: game.currentWord,
            feedback: game.wordFeedback,
            points: game.lastWordPoints,
            isValidating: game.isValidating,
          ),
          const SizedBox(height: 16),

          // Botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: game.currentWord.isEmpty
                      ? null
                      : notifier.clearSelection,
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: game.currentWord.length >= 2 && !game.isValidating
                      ? notifier.submitWord
                      : null,
                  child: game.isValidating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enviar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordDisplay extends StatelessWidget {
  const _WordDisplay({
    required this.word,
    required this.feedback,
    this.points,
    required this.isValidating,
  });

  final String word;
  final WordFeedback feedback;
  final int? points;
  final bool isValidating;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.surfaceVariant;
    String subtitle = '';

    if (feedback == WordFeedback.valid) {
      borderColor = AppColors.success;
      subtitle = '+${points ?? 0} pts';
    } else if (feedback == WordFeedback.invalid) {
      borderColor = AppColors.error;
      subtitle = 'Palavra inválida';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            word.isEmpty ? '— selecione letras —' : word,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: word.isEmpty
                  ? AppColors.onSurfaceMuted
                  : AppColors.onBackground,
              letterSpacing: word.isEmpty ? 0 : 4,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: feedback == WordFeedback.valid
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Round End ────────────────────────────────────────────────────────────────

class _RoundEndView extends ConsumerWidget {
  const _RoundEndView({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myScore = game.myScore;
    final opponentScore = game.opponentScore;
    final iWon = myScore > opponentScore;
    final isDraw = myScore == opponentScore;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isDraw
                  ? 'Empate!'
                  : iWon
                      ? '${game.currentPlayer?.username ?? "Você"} venceu a rodada!'
                      : '${game.opponentPlayer?.username ?? "Oponente"} venceu!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScorePill(
                  label: game.currentPlayer?.username ?? 'Você',
                  score: myScore,
                  isLocal: true,
                ),
                _ScorePill(
                  label: game.opponentPlayer?.username ?? 'Oponente',
                  score: opponentScore,
                  isLocal: false,
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  ref.read(gameNotifierProvider.notifier).proceedToNextRound(),
              child: Text(
                game.isLastRound ? 'Ver resultado final' : 'Próxima rodada',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.score,
    required this.isLocal,
  });

  final String label;
  final int score;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isLocal ? AppColors.primary : AppColors.secondary,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isLocal ? AppColors.primary : AppColors.secondary,
              ),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({required this.theme});
  final String theme;

  String _themeLabel(String t) {
    const labels = {
      'food': 'Culinária',
      'animals': 'Animais',
      'sports': 'Esportes',
      'tech': 'Tecnologia',
    };
    return labels[t] ?? t;
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('Tema: ${_themeLabel(theme)}'),
      backgroundColor: AppColors.surfaceVariant,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.onSurface,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
