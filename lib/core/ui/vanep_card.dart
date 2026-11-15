import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepCard extends StatelessWidget {
  const VanepCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.highlighted = false,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? context.palette.actionSurface : context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: BorderSide(
          color:
              borderColor ??
              (highlighted
                  ? context.palette.action
                  : context.palette.cardBorder),
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
