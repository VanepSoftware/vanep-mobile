import 'package:flutter/animation.dart';

import 'package:vanep_mobile/core/ui/vanep_logo_glyphs.dart';

const Duration vanepIntroDuration = Duration(milliseconds: 2000);

const double vanepSheenRestCenter = 0.78;
const double vanepSheenStartCenter = -0.3;
const double vanepLogoStartScale = 0.92;

const double vanepFirstLetterStart = 0.10;
const double vanepLetterStagger = 0.07;
const double vanepLetterRevealLength = 0.30;

const Interval vanepBackdropRevealInterval = Interval(
  0,
  0.25,
  curve: Curves.easeOut,
);
const Interval vanepLogoScaleInterval = Interval(
  0.05,
  0.75,
  curve: Curves.easeOutCubic,
);
const Interval vanepSheenSweepInterval = Interval(
  0.40,
  0.90,
  curve: Curves.easeInOutCubic,
);
const Interval vanepOverlayFadeOutInterval = Interval(
  0.88,
  1,
  curve: Curves.easeIn,
);

final List<double> vanepLogoFullyRevealed = List.unmodifiable(
  List.filled(vanepLogoLetters.length, 1.0),
);

class VanepIntroFrame {
  const VanepIntroFrame({
    required this.backdropReveal,
    required this.letterReveals,
    required this.logoScale,
    required this.sheenCenter,
  });

  factory VanepIntroFrame.at(double progress) {
    final scaleProgress = vanepLogoScaleInterval.transform(progress);
    final sheenProgress = vanepSheenSweepInterval.transform(progress);
    return VanepIntroFrame(
      backdropReveal: vanepBackdropRevealInterval.transform(progress),
      letterReveals: List.generate(
        vanepLogoLetters.length,
        (letterIndex) => revealVanepLetter(letterIndex, progress),
      ),
      logoScale:
          vanepLogoStartScale + (1 - vanepLogoStartScale) * scaleProgress,
      sheenCenter:
          vanepSheenStartCenter +
          (vanepSheenRestCenter - vanepSheenStartCenter) * sheenProgress,
    );
  }

  factory VanepIntroFrame.rest() {
    return VanepIntroFrame(
      backdropReveal: 1,
      letterReveals: vanepLogoFullyRevealed,
      logoScale: 1,
      sheenCenter: vanepSheenRestCenter,
    );
  }

  final double backdropReveal;
  final List<double> letterReveals;
  final double logoScale;
  final double sheenCenter;
}

double revealVanepLetter(int letterIndex, double progress) {
  final start = vanepFirstLetterStart + letterIndex * vanepLetterStagger;
  return Interval(
    start,
    start + vanepLetterRevealLength,
    curve: Curves.easeOutCubic,
  ).transform(progress);
}

double fadeOutVanepIntroOverlay(double progress) {
  return 1 - vanepOverlayFadeOutInterval.transform(progress);
}
