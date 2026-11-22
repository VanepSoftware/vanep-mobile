import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';

class ClientVansSkeleton extends StatelessWidget {
  const ClientVansSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepSkeletonList(
      count: 2,
      spacing: 16,
      buildPlaceholder: _buildPlaceholder,
    );
  }
}

Widget _buildPlaceholder(BuildContext context) {
  return const VanepCard(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(words: 3, fontSize: 18),
        SizedBox(height: 8),
        Bone.text(words: 4, fontSize: 13),
        SizedBox(height: 16),
        Bone(
          height: 120,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        SizedBox(height: 16),
        Bone.text(words: 5, fontSize: 14),
        SizedBox(height: 8),
        Bone.text(words: 3, fontSize: 13),
        SizedBox(height: 18),
        Bone(
          height: 52,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ],
    ),
  );
}
