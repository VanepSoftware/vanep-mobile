import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../design_system/vanep_colors.dart';

/// Shimmering placeholder zone shown while an API response is pending.
///
/// Only [Bone] descendants are shaded, so every placeholder is written
/// explicitly instead of faking domain entities.
class VanepSkeleton extends StatelessWidget {
  const VanepSkeleton({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      enabled: enabled,
      effect: const ShimmerEffect(
        baseColor: VanepColors.skeletonBase,
        highlightColor: VanepColors.skeletonHighlight,
      ),
      child: child,
    );
  }
}

/// Repeats a card placeholder [count] times with the same spacing the real
/// list uses, so the layout does not jump once the data arrives.
class VanepSkeletonList extends StatelessWidget {
  const VanepSkeletonList({
    required this.buildPlaceholder,
    this.count = 3,
    this.spacing = 12,
    super.key,
  });

  final WidgetBuilder buildPlaceholder;
  final int count;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return VanepSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (
            var placeholderIndex = 0;
            placeholderIndex < count;
            placeholderIndex++
          )
            Padding(
              padding: EdgeInsets.only(
                bottom: placeholderIndex == count - 1 ? 0 : spacing,
              ),
              child: buildPlaceholder(context),
            ),
        ],
      ),
    );
  }
}
