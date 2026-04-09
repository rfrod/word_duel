import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/game_state.dart';

/// Widget para selecionar a aposta de tempo antes de cada rodada.
class BetSelector extends StatelessWidget {
  const BetSelector({
    super.key,
    required this.selectedBet,
    required this.onBetSelected,
    this.isConfirmed = false,
  });

  final BetOption? selectedBet;
  final ValueChanged<BetOption> onBetSelected;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: BetOption.values.map((bet) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _BetCard(
            bet: bet,
            isSelected: selectedBet == bet,
            isConfirmed: isConfirmed,
            onTap: isConfirmed ? null : () => onBetSelected(bet),
          ),
        );
      }).toList(),
    );
  }
}

class _BetCard extends StatelessWidget {
  const _BetCard({
    required this.bet,
    required this.isSelected,
    required this.isConfirmed,
    this.onTap,
  });

  final BetOption bet;
  final bool isSelected;
  final bool isConfirmed;
  final VoidCallback? onTap;

  Color get _betColor {
    switch (bet) {
      case BetOption.fast:
        return AppColors.betFast;
      case BetOption.normal:
        return AppColors.betNormal;
      case BetOption.slow:
        return AppColors.betSlow;
    }
  }

  String _label(BuildContext context) {
    switch (bet) {
      case BetOption.fast:
        return '10s  ×2,0 pts';
      case BetOption.normal:
        return '15s  ×1,0 pt';
      case BetOption.slow:
        return '20s  ×0,5 pt';
    }
  }

  String _description(BuildContext context) {
    switch (bet) {
      case BetOption.fast:
        return 'Alto risco, alta recompensa';
      case BetOption.normal:
        return 'Equilibrado';
      case BetOption.slow:
        return 'Seguro, pontuação menor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _betColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.surfaceVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${bet.seconds}s',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _label(context),
                        style: TextStyle(
                          color: isSelected ? color : AppColors.onBackground,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _description(context),
                        style: const TextStyle(
                          color: AppColors.onSurfaceMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
