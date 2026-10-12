import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_brand_backdrop.dart';
import 'package:vanep_mobile/core/ui/vanep_brand_splash.dart';
import 'package:vanep_mobile/core/ui/vanep_logo.dart';
import 'package:vanep_mobile/core/ui/vanep_logo_glyphs.dart';
import 'package:vanep_mobile/core/ui/vanep_van_intro_timeline.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const double vanepSpeedLineOpacity = 0.28;
const double vanepVanShadowOpacity = 0.25;

class VanepVanIntroOverlay extends StatelessWidget {
  const VanepVanIntroOverlay({required this.progress, super.key});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Semantics(
        label: AppLocalizations.of(context)!.appTitle,
        image: true,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => Opacity(
            opacity: fadeOutVanepVanIntro(progress.value),
            child: VanepBrandBackdrop(
              gradientOpacity: vanepVanBackdropInterval.transform(
                progress.value,
              ),
              child: CustomPaint(
                painter: VanepVanIntroPainter(progress: progress.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VanepVanIntroPainter extends CustomPainter {
  VanepVanIntroPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final logoRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: vanepSplashLogoWidth,
      height: vanepSplashLogoWidth * vanepLogoHeight / vanepLogoWidth,
    );
    final groundY =
        logoRect.top + vanepLogoXHeight * logoRect.width / vanepLogoWidth;
    final vanCenterX = findVanepVanCenterX(progress, size.width);
    final vanRearX = vanCenterX - vanepVanWidth / 2;

    paintVanepSmoke(
      canvas,
      findVanepSmokePuffs(
        progress: progress,
        screenWidth: size.width,
        groundY: groundY,
      ),
    );
    paintLettersBehindVan(canvas, logoRect: logoRect, vanRearX: vanRearX);
    if (!isVanepVanDriving(progress)) return;
    final vanTop = groundY - vanepVanHeight + findVanepVanBounce(progress);
    paintVanepSpeedLines(canvas, vanRearX: vanRearX, vanTop: vanTop);
    paintVanepVanShadow(canvas, vanCenterX: vanCenterX, groundY: groundY);
    paintVanepVan(
      canvas,
      origin: Offset(vanRearX, vanTop),
      wheelTurn: vanCenterX / vanepVanWheelRadius,
    );
  }

  @override
  bool shouldRepaint(VanepVanIntroPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

void paintVanepSmoke(Canvas canvas, List<VanepSmokePuff> puffs) {
  for (final puff in puffs) {
    canvas.drawCircle(
      puff.center,
      puff.radius,
      Paint()..color = VanepColors.vanSmoke.withValues(alpha: puff.opacity),
    );
  }
}

void paintLettersBehindVan(
  Canvas canvas, {
  required Rect logoRect,
  required double vanRearX,
}) {
  final logoScale = logoRect.width / vanepLogoWidth;
  for (final letter in vanepLogoLetters) {
    final letterCenterX =
        logoRect.left + letter.getBounds().center.dx * logoScale;
    canvas
      ..save()
      ..translate(logoRect.left, logoRect.top)
      ..scale(logoScale);
    paintVanepLetter(
      canvas,
      letter: letter,
      reveal: revealLetterBehindVan(
        letterCenterX: letterCenterX,
        vanRearX: vanRearX,
      ),
      color: VanepColors.onBrand,
    );
    canvas.restore();
  }
}

void paintVanepSpeedLines(
  Canvas canvas, {
  required double vanRearX,
  required double vanTop,
}) {
  final paint = Paint()
    ..color = VanepColors.onBrand.withValues(alpha: vanepSpeedLineOpacity);
  const lines = [
    (top: 14.0, length: 22.0),
    (top: 24.0, length: 30.0),
    (top: 34.0, length: 18.0),
  ];
  for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          vanRearX - line.length - 8 - lineIndex * 4,
          vanTop + line.top * vanepVanScale,
          line.length,
          2,
        ),
        const Radius.circular(1),
      ),
      paint,
    );
  }
}

void paintVanepVanShadow(
  Canvas canvas, {
  required double vanCenterX,
  required double groundY,
}) {
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(vanCenterX, groundY + 1),
      width: vanepVanWidth * 0.92,
      height: 6,
    ),
    Paint()
      ..color = VanepColors.vanShadow.withValues(alpha: vanepVanShadowOpacity),
  );
}

void paintVanepVan(
  Canvas canvas, {
  required Offset origin,
  required double wheelTurn,
}) {
  canvas
    ..save()
    ..translate(origin.dx, origin.dy)
    ..scale(vanepVanScale)
    ..drawRRect(
      RRect.fromLTRBR(-6, 38, 1, 41.5, const Radius.circular(1.5)),
      Paint()..color = VanepColors.vanExhaust,
    )
    ..drawPath(buildVanepVanBody(), Paint()..color = VanepColors.onBrand)
    ..drawPath(buildVanepVanWindows(), Paint()..color = VanepColors.vanWindow)
    ..drawRect(
      const Rect.fromLTWH(0, 27, 100, 4),
      Paint()..color = VanepColors.brandSheen,
    )
    ..drawRRect(
      RRect.fromLTRBR(94, 32, 100, 37, const Radius.circular(1.5)),
      Paint()..color = VanepColors.vanHeadlight,
    )
    ..drawRRect(
      RRect.fromLTRBR(0, 32, 3, 38, const Radius.circular(1)),
      Paint()..color = VanepColors.vanTaillight,
    );
  paintVanepWheel(canvas, center: const Offset(22, 46), turn: wheelTurn);
  paintVanepWheel(canvas, center: const Offset(78, 46), turn: wheelTurn);
  canvas.restore();
}

void paintVanepWheel(
  Canvas canvas, {
  required Offset center,
  required double turn,
}) {
  final hubPaint = Paint()..color = VanepColors.vanHub;
  canvas
    ..save()
    ..translate(center.dx, center.dy)
    ..drawCircle(
      Offset.zero,
      10,
      Paint()..color = VanepColors.brandNavyDeep,
    )
    ..drawCircle(Offset.zero, 4.2, hubPaint)
    ..rotate(turn)
    ..drawRect(const Rect.fromLTWH(-1, -8.5, 2, 4), hubPaint)
    ..drawRect(const Rect.fromLTWH(-1, 4.5, 2, 4), hubPaint)
    ..restore();
}

Path buildVanepVanBody() => Path()
  ..moveTo(0, 44)
  ..lineTo(0, 8)
  ..quadraticBezierTo(0, 0, 8, 0)
  ..lineTo(60, 0)
  ..quadraticBezierTo(64, 0, 66, 3)
  ..lineTo(80, 19)
  ..lineTo(94, 23)
  ..quadraticBezierTo(100, 25, 100, 31)
  ..lineTo(100, 44)
  ..close();

Path buildVanepVanWindows() => Path()
  ..addRect(const Rect.fromLTWH(6, 6, 22, 13))
  ..addRect(const Rect.fromLTWH(32, 6, 22, 13))
  ..moveTo(58, 6)
  ..lineTo(64, 6)
  ..lineTo(76, 19)
  ..lineTo(58, 19)
  ..close();
