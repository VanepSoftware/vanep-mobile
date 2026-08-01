import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

class VanepScreenBackground extends StatelessWidget {
  const VanepScreenBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            VanepColors.surfaceGradientTop,
            VanepColors.surfaceGradientBottom,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.4, -0.7),
                  radius: 1.1,
                  colors: [
                    VanepColors.glowPrimary,
                    VanepColors.glowPrimaryFade,
                  ],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
