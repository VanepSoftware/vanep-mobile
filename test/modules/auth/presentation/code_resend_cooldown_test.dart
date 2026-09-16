import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/code_resend_cooldown.dart';

void main() {
  test('counts down every second from the configured duration', () {
    fakeAsync((async) {
      final secondsLeft = <int>[];
      final cooldown = CodeResendCooldown(seconds: 3);

      cooldown.start(secondsLeft.add);
      async.elapse(const Duration(seconds: 5));

      expect(secondsLeft, [3, 2, 1, 0]);
    });
  });

  test('restarting cancels the previous countdown', () {
    fakeAsync((async) {
      final secondsLeft = <int>[];
      final cooldown = CodeResendCooldown(seconds: 2);

      cooldown.start(secondsLeft.add);
      async.elapse(const Duration(seconds: 1));
      cooldown.start(secondsLeft.add);
      async.elapse(const Duration(seconds: 3));

      expect(secondsLeft, [2, 1, 2, 1, 0]);
    });
  });

  test('cancel stops the countdown', () {
    fakeAsync((async) {
      final secondsLeft = <int>[];
      final cooldown = CodeResendCooldown(seconds: 3);

      cooldown.start(secondsLeft.add);
      cooldown.cancel();
      async.elapse(const Duration(seconds: 3));

      expect(secondsLeft, [3]);
    });
  });
}
