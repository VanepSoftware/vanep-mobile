import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_card.dart';

class FindVanSkeletonList extends StatelessWidget {
  const FindVanSkeletonList({this.count = 3, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: count,
      buildPlaceholder: (context) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: DriverCardSkeleton(),
      ),
    );
  }
}
