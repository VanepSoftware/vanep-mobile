import 'dart:async';

const int defaultResendCooldownSeconds = 60;

class CodeResendCooldown {
  CodeResendCooldown({this.seconds = defaultResendCooldownSeconds});

  final int seconds;
  Timer? _timer;

  void start(void Function(int secondsLeft) onSecondsLeft) {
    cancel();
    var secondsLeft = seconds;
    onSecondsLeft(secondsLeft);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      onSecondsLeft(secondsLeft);
      if (secondsLeft <= 0) timer.cancel();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
