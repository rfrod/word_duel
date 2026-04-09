import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Grade 5×3 com as 15 letras do tabuleiro.
///
/// - [letters]: lista de 15 letras
/// - [selectedIndices]: índices selecionados pelo jogador local (roxo)
/// - [opponentIndices]: índices selecionados pelo oponente (vermelho)
/// - [onTileTap]: callback ao tocar em uma tile
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.letters,
    required this.selectedIndices,
    required this.opponentIndices,
    required this.onTileTap,
    this.enabled = true,
  });

  final List<String> letters;
  final List<int> selectedIndices;
  final List<int> opponentIndices;
  final ValueChanged<int> onTileTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const columns = 5;
    const rows = 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: rows * columns,
      itemBuilder: (context, index) {
        final isSelected = selectedIndices.contains(index);
        final isOpponent = opponentIndices.contains(index);
        final letter = index < letters.length ? letters[index] : '';

        return _Tile(
          letter: letter,
          isSelected: isSelected,
          isOpponent: isOpponent,
          selectionOrder: isSelected ? selectedIndices.indexOf(index) + 1 : null,
          onTap: enabled ? () => onTileTap(index) : null,
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.letter,
    required this.isSelected,
    required this.isOpponent,
    this.selectionOrder,
    this.onTap,
  });

  final String letter;
  final bool isSelected;
  final bool isOpponent;
  final int? selectionOrder;
  final VoidCallback? onTap;

  Color get _backgroundColor {
    if (isSelected) return AppColors.tileSelected;
    if (isOpponent) return AppColors.tileOpponent.withOpacity(0.4);
    return AppColors.tileDefault;
  }

  Color get _borderColor {
    if (isSelected) return AppColors.primary;
    if (isOpponent) return AppColors.tileOpponent;
    return AppColors.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: isSelected ? 2 : 1),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                letter,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : AppColors.onBackground,
                ),
              ),
              if (selectionOrder != null)
                Positioned(
                  top: 4,
                  right: 6,
                  child: Text(
                    '$selectionOrder',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
