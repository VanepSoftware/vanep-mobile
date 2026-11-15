import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';

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
    this.sheenCenter = vanepSheenRestCenter,
    super.key,
  });

  final Widget child;
  final double gradientOpacity;
  final double sheenCenter;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
            decoration: BoxDecoration(
              gradient: buildVanepSheenGradient(sheenCenter),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

LinearGradient buildVanepSheenGradient(double center) {
  final glow = VanepColors.brandSheen.withValues(alpha: vanepSheenOpacity);
  final clear = VanepColors.brandSheen.withValues(alpha: 0);
  return LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [clear, glow, clear],
    stops: [
      (center - vanepSheenHalfWidth).clamp(0.0, 1.0),
      center.clamp(0.0, 1.0),
      (center + vanepSheenHalfWidth).clamp(0.0, 1.0),
    ],
  );
}
