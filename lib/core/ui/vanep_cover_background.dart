import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepCoverBackground extends StatelessWidget {
  const VanepCoverBackground({
    required this.child,
    this.photoUrl,
    this.fallbackColor,
    super.key,
  });

  final Widget child;
  final String? photoUrl;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final image = apiImageFor(context, photoUrl);
    if (image == null) {
      return ColoredBox(
        color: fallbackColor ?? context.palette.actionSurface,
        child: child,
      );
    }

    return ColoredBox(
      color: VanepColors.photoScrim,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          const Positioned.fill(child: VanepCoverScrim()),
          child,
        ],
      ),
    );
  }
}

class VanepCoverScrim extends StatelessWidget {
  const VanepCoverScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            VanepColors.photoScrim.withValues(alpha: 0.35),
            VanepColors.photoScrim.withValues(alpha: 0.75),
          ],
        ),
      ),
    );
  }
}
