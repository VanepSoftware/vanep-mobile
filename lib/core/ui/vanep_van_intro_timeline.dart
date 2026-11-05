import 'dart:math' as math;

import 'package:flutter/widgets.dart';

const Duration vanepVanIntroDuration = Duration(milliseconds: 2800);

const double vanepVanScale = 0.95;
const double vanepVanWidth = 100 * vanepVanScale;
const double vanepVanHeight = 56 * vanepVanScale;
const double vanepVanWheelRadius = 10 * vanepVanScale;

const double vanepLetterRevealLead = 20;
const double vanepLetterRevealDistance = 36;

const double vanepSmokeEmitEvery = 0.013;
const double vanepSmokeLifetime = 0.17;
const double vanepSmokeMaxOpacity = 0.45;

const Interval vanepVanDriveInterval = Interval(
  0.06,
  0.78,
  curve: Curves.easeInOutSine,
);
const Interval vanepVanBackdropInterval = Interval(
  0,
  0.15,
  curve: Curves.easeOut,
);
const Interval vanepVanFadeOutInterval = Interval(
  0.90,
  1,
  curve: Curves.easeIn,
);

class VanepSmokePuff {
  const VanepSmokePuff({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  final Offset center;
  final double radius;
  final double opacity;
}

bool isVanepVanDriving(double progress) {
  return progress > vanepVanDriveInterval.begin &&
      progress < vanepVanDriveInterval.end;
}

double findVanepVanCenterX(double progress, double screenWidth) {
  final travel = screenWidth + 2 * vanepVanWidth;
  return -vanepVanWidth + travel * vanepVanDriveInterval.transform(progress);
}

double findVanepVanBounce(double progress) {
  if (!isVanepVanDriving(progress)) return 0;
  return math.sin(progress * 90) * 0.8;
}

double revealLetterBehindVan({
  required double letterCenterX,
  required double vanRearX,
}) {
  final passed =
      (vanRearX - letterCenterX + vanepLetterRevealLead) /
      vanepLetterRevealDistance;
  return Curves.easeOutCubic.transform(passed.clamp(0.0, 1.0));
}

double fadeOutVanepVanIntro(double progress) {
  return 1 - vanepVanFadeOutInterval.transform(progress);
}

List<VanepSmokePuff> findVanepSmokePuffs({
  required double progress,
  required double screenWidth,
  required double groundY,
}) {
  final driveLength = vanepVanDriveInterval.end - vanepVanDriveInterval.begin;
  final puffCount = (driveLength / vanepSmokeEmitEvery).floor() + 1;
  final puffs = <VanepSmokePuff>[];
  for (var puffIndex = 0; puffIndex < puffCount; puffIndex++) {
    final emittedAt =
        vanepVanDriveInterval.begin + puffIndex * vanepSmokeEmitEvery;
    final age = (progress - emittedAt) / vanepSmokeLifetime;
    if (age < 0 || age >= 1) continue;
    final exhaust = Offset(
      findVanepVanCenterX(emittedAt, screenWidth) - vanepVanWidth / 2 - 3,
      groundY - 8,
    );
    puffs.add(
      buildVanepSmokePuff(puffIndex: puffIndex, age: age, exhaust: exhaust),
    );
  }
  return puffs;
}

VanepSmokePuff buildVanepSmokePuff({
  required int puffIndex,
  required double age,
  required Offset exhaust,
}) {
  final jitterX = (puffIndex * 37 % 11) / 10 - 0.5;
  final jitterY = (puffIndex * 53 % 7) / 6 - 0.5;
  final rise = Curves.easeOut.transform(age);
  return VanepSmokePuff(
    center: exhaust.translate(-8 * age + jitterX * 8, -16 * rise + jitterY * 5),
    radius: 2 + 7 * rise + jitterX.abs() * 2,
    opacity: vanepSmokeMaxOpacity * math.pow(1 - age, 1.6).toDouble(),
  );
}
