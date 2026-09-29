import 'package:flutter/material.dart';

import '../../../../core/ui/vanep_greeting_header.dart';
import '../../../../core/ui/vanep_home_top_bar.dart';
import '../widgets/no_linked_van_card.dart';

class ClientHomeTab extends StatelessWidget {
  const ClientHomeTab({
    required this.displayName,
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    required this.onFindVanTapped,
    super.key,
  });

  final String displayName;
  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;
  final VoidCallback onFindVanTapped;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          VanepHomeTopBar(
            onMenuTapped: onMenuTapped,
            onNotificationsTapped: onNotificationsTapped,
          ),
          const SizedBox(height: 8),
          VanepGreetingHeader(displayName: displayName),
          const SizedBox(height: 24),
          NoLinkedVanCard(onFindVanTapped: onFindVanTapped),
        ],
      ),
    );
  }
}
