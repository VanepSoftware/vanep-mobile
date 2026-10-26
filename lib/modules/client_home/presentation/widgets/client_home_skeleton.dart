import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';

class ClientHomeSkeleton extends StatelessWidget {
  const ClientHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: 3,
      buildPlaceholder: (_) => const VanepCard(
        child: Row(
          children: [
            Bone.circle(size: 40),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(words: 3, fontSize: 16),
                  SizedBox(height: 6),
                  Bone.text(width: 140, fontSize: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
