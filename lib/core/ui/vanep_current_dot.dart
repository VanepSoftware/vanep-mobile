import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const currentDotSize = 10.0;

const currentDotHaloWidth = 3.0;

class VanepCurrentDot extends StatelessWidget {
  const VanepCurrentDot({
    required this.isCurrent,
    this.semanticLabel,
    super.key,
  });

  final bool isCurrent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: currentDotSize,
      height: currentDotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent ? context.palette.action : context.palette.textMuted,
        border: isCurrent
            ? Border.all(
                color: context.palette.actionHalo,
                width: currentDotHaloWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
    );
    final label = semanticLabel;
    if (!isCurrent || label == null) return ExcludeSemantics(child: dot);
    return Semantics(label: label, child: dot);
  }
}
