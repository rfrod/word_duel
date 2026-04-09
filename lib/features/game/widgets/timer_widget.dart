import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../notifiers/timer_notifier.dart';

/// Timer circular animado desenhado com CustomPainter.
/// Muda de cor conforme o tempo restante:
///   > 50%  → roxo (normal)
///   ≤ 50%  → amarelo (aviso)
///   ≤ 25%  → vermelho (perigo)
class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerNotifierProvider);

    final color = timer.isDanger
        ? AppColors.timerDanger
        : timer.isWarning
            ? AppColors.timerWarning
            : AppColors.timerNormal;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _TimerPainter(
              progress: timer.progress,
              color: color,
              trackColor: AppColors.timerTrack,
              strokeWidth: size * 0.1,
            ),
          ),
          Text(
            '${timer.remainingSeconds}',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  const _TimerPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Trilha de fundo
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Arco do progresso (sentido horário, começa do topo)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // começa do topo
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.progress != progress || old.color != color;
}
