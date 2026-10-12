import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';

void main() {
  test('starts with the letters hidden and the gradient not revealed', () {
    final frame = VanepIntroFrame.at(0);

    expect(frame.letterReveals, everyElement(0.0));
    expect(frame.backdropReveal, 0);
    expect(frame.logoScale, vanepLogoStartScale);
    expect(frame.sheenCenter, vanepSheenStartCenter);
  });

  test('reveals the letters one after the other from left to right', () {
    final reveals = VanepIntroFrame.at(0.4).letterReveals;

    for (var letterIndex = 1; letterIndex < reveals.length; letterIndex++) {
      expect(reveals[letterIndex], lessThan(reveals[letterIndex - 1]));
    }
  });

  test('settles exactly on the resting splash frame', () {
    final last = VanepIntroFrame.at(1);
    final rest = VanepIntroFrame.rest();

    expect(last.letterReveals, rest.letterReveals);
    expect(last.backdropReveal, rest.backdropReveal);
    expect(last.logoScale, closeTo(rest.logoScale, 1e-9));
    expect(last.sheenCenter, closeTo(rest.sheenCenter, 1e-9));
  });

  test('keeps the overlay opaque until the closing fade', () {
    expect(fadeOutVanepIntroOverlay(0.5), 1);
    expect(fadeOutVanepIntroOverlay(0.95), inExclusiveRange(0, 1));
    expect(fadeOutVanepIntroOverlay(1), 0);
  });
}
