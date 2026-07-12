import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

class VanepGradientBackground extends StatelessWidget {
  const VanepGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.6, 1),
          colors: [
            VanepColors.backgroundDeep,
            VanepColors.backgroundMid,
            VanepColors.backgroundSoft,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.44, -0.24),
                  radius: 1.1,
                  colors: [
                    VanepColors.glowPrimary,
                    VanepColors.glowPrimaryFade,
                  ],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.84, 0.76),
                  radius: 1.0,
                  colors: [
                    VanepColors.glowSecondary,
                    VanepColors.glowSecondaryFade,
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
