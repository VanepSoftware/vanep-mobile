import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';

class FindVanSkeletonList extends StatelessWidget {
  const FindVanSkeletonList({this.count = 3, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: count,
      buildPlaceholder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.palette.cardBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.circle(size: 48),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(words: 2, fontSize: 15),
                      SizedBox(height: 6),
                      Bone.text(words: 3, fontSize: 12),
                      SizedBox(height: 6),
                      Bone.text(words: 3, fontSize: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Bone.text(width: 160, fontSize: 12),
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(width: 84, fontSize: 16),
                Bone.button(width: 132, height: 38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
