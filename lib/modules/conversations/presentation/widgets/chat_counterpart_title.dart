import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';

class ChatCounterpartTitle extends StatelessWidget {
  const ChatCounterpartTitle({
    required this.name,
    required this.role,
    super.key,
  });

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VanepPersonAvatar(name: name, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: VanepTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                role,
                style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
