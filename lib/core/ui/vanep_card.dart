import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_theme.dart';

class VanepCard extends StatelessWidget {
  const VanepCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.highlighted = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? VanepColors.actionSurface : VanepColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: BorderSide(
          color: highlighted ? VanepColors.action : VanepColors.cardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
