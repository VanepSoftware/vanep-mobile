import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class ProposalsEmptyState extends StatelessWidget {
  const ProposalsEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    return VanepCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          VanepIconBadge(icon: icon),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.typography.cardTitle,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.cardSubtitle,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            VanepSecondaryButton(
              label: actionLabel,
              icon: Icons.search,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
