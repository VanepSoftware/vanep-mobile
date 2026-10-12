import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';

const double vanepSheenCenter = 0.78;
const double vanepSheenHalfWidth = 0.22;
const double vanepSheenOpacity = 0.10;

const LinearGradient vanepBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    VanepColors.brandNavyDeep,
    VanepColors.brandNavy,
    VanepColors.brandNavyBright,
  ],
);

class VanepBrandBackdrop extends StatelessWidget {
  const VanepBrandBackdrop({
    required this.child,
    this.gradientOpacity = 1,
    super.key,
  });

  final Widget child;
  final double gradientOpacity;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: VanepColors.brandNavy,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: gradientOpacity,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: vanepBrandGradient),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: buildVanepSheenGradient()),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

LinearGradient buildVanepSheenGradient() {
  final glow = VanepColors.brandSheen.withValues(alpha: vanepSheenOpacity);
  final clear = VanepColors.brandSheen.withValues(alpha: 0);
  return LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [clear, glow, clear],
    stops: const [
      vanepSheenCenter - vanepSheenHalfWidth,
      vanepSheenCenter,
      vanepSheenCenter + vanepSheenHalfWidth,
    ],
  );
}
