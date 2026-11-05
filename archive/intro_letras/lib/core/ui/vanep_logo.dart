import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';
import 'package:vanep_mobile/core/ui/vanep_logo_glyphs.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const double vanepLetterRiseFactor = 0.45;

class VanepLogo extends StatelessWidget {
  const VanepLogo({
    required this.width,
    this.color = VanepColors.onBrand,
    this.letterReveals,
    super.key,
  });

  final double width;
  final Color color;
  final List<double>? letterReveals;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)!.appTitle,
      image: true,
      child: CustomPaint(
        size: Size(width, width * vanepLogoHeight / vanepLogoWidth),
        painter: VanepLogoPainter(
          color: color,
          letterReveals: letterReveals ?? vanepLogoFullyRevealed,
        ),
      ),
    );
  }
}

class VanepLogoPainter extends CustomPainter {
  VanepLogoPainter({required this.color, required this.letterReveals});

  final Color color;
  final List<double> letterReveals;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / vanepLogoWidth);
    for (
      var letterIndex = 0;
      letterIndex < vanepLogoLetters.length;
      letterIndex++
    ) {
      paintVanepLetter(
        canvas,
        letter: vanepLogoLetters[letterIndex],
        reveal: letterReveals[letterIndex],
        color: color,
      );
    }
  }

  @override
  bool shouldRepaint(VanepLogoPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.letterReveals != letterReveals;
  }
}

void paintVanepLetter(
  Canvas canvas, {
  required Path letter,
  required double reveal,
  required Color color,
}) {
  if (reveal <= 0) return;
  final riseOffset = (1 - reveal) * vanepLogoXHeight * vanepLetterRiseFactor;
  final paint = Paint()..color = color.withValues(alpha: color.a * reveal);
  canvas
    ..save()
    ..translate(0, riseOffset)
    ..drawPath(letter, paint)
    ..restore();
}
