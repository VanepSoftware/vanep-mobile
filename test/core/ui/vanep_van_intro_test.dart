import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_van_intro.dart';
import 'package:vanep_mobile/core/ui/vanep_van_intro_timeline.dart';

const double screenWidth = 390;
const double groundY = 420;

void main() {
  test('the van enters from off-screen left and leaves off-screen right', () {
    final startRight = findVanepVanCenterX(0, screenWidth) + vanepVanWidth / 2;
    final endLeft = findVanepVanCenterX(1, screenWidth) - vanepVanWidth / 2;

    expect(startRight, lessThanOrEqualTo(0));
    expect(endLeft, greaterThanOrEqualTo(screenWidth));
  });

  test('only bounces while the van is driving', () {
    expect(isVanepVanDriving(0), isFalse);
    expect(isVanepVanDriving(0.4), isTrue);
    expect(isVanepVanDriving(1), isFalse);
    expect(findVanepVanBounce(1), 0);
  });

  test('a letter appears only after the back of the van has passed it', () {
    expect(revealLetterBehindVan(letterCenterX: 200, vanRearX: 100), 0);
    expect(revealLetterBehindVan(letterCenterX: 200, vanRearX: 300), 1);
    expect(
      revealLetterBehindVan(letterCenterX: 200, vanRearX: 190),
      inExclusiveRange(0, 1),
    );
  });

  test('leaves smoke only while the van is on screen', () {
    List<VanepSmokePuff> puffsAt(double progress) => findVanepSmokePuffs(
      progress: progress,
      screenWidth: screenWidth,
      groundY: groundY,
    );

    expect(puffsAt(0), isEmpty);
    expect(puffsAt(1), isEmpty);
    final midDrive = puffsAt(0.4);
    expect(midDrive, isNotEmpty);
    for (final puff in midDrive) {
      expect(puff.opacity, inInclusiveRange(0, vanepSmokeMaxOpacity));
      expect(puff.radius, greaterThan(0));
    }
  });

  test('a smoke puff grows and fades as it ages', () {
    const exhaust = Offset(100, 400);
    final fresh = buildVanepSmokePuff(puffIndex: 3, age: 0, exhaust: exhaust);
    final old = buildVanepSmokePuff(puffIndex: 3, age: 0.9, exhaust: exhaust);

    expect(old.radius, greaterThan(fresh.radius));
    expect(old.opacity, lessThan(fresh.opacity));
    expect(old.center.dy, lessThan(fresh.center.dy));
  });

  test('keeps the overlay opaque until the closing fade', () {
    expect(fadeOutVanepVanIntro(0.5), 1);
    expect(fadeOutVanepVanIntro(1), 0);
  });

  test('repaints whenever the intro moves forward', () {
    final painter = VanepVanIntroPainter(progress: 0.3);

    expect(painter.shouldRepaint(VanepVanIntroPainter(progress: 0.3)), isFalse);
    expect(painter.shouldRepaint(VanepVanIntroPainter(progress: 0.31)), isTrue);
  });
}
