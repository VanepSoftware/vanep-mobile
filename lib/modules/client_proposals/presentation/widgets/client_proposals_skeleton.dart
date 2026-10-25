import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';

class ClientProposalsSkeleton extends StatelessWidget {
  const ClientProposalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: 2,
      buildPlaceholder: (_) => const VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Bone.circle(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(words: 2, fontSize: 15),
                      SizedBox(height: 6),
                      Bone.text(width: 120, fontSize: 13),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Bone(height: 64, width: double.infinity),
            SizedBox(height: 14),
            Bone.text(width: 100, fontSize: 20),
          ],
        ),
      ),
    );
  }
}
