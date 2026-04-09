import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const TimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
  });

  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;

  bool get isExpired => remainingSeconds <= 0;

  bool get isDanger => remainingSeconds <= totalSeconds * 0.25;
  bool get isWarning => remainingSeconds <= totalSeconds * 0.5;
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
      : super(const TimerState(totalSeconds: 10, remainingSeconds: 10));

  Timer? _timer;
  void Function()? _onExpired;

  /// Inicia o contador regressivo.
  void start(int seconds, {void Function()? onExpired}) {
    _timer?.cancel();
    _onExpired = onExpired;

    state = TimerState(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        state = TimerState(
          totalSeconds: state.totalSeconds,
          remainingSeconds: 0,
          isRunning: false,
        );
        _timer?.cancel();
        _onExpired?.call();
      } else {
        state = TimerState(
          totalSeconds: state.totalSeconds,
          remainingSeconds: next,
          isRunning: true,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = TimerState(
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.remainingSeconds,
      isRunning: false,
    );
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.totalSeconds,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Não usar autoDispose: o GameNotifier inicia o timer via _ref.read()
// antes da TimerWidget se inscrever, então o provider não pode ser descartado.
final timerNotifierProvider =
    StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(),
);
