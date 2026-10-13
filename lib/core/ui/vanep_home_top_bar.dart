import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';

const BoxConstraints _edgeAlignedTapTarget = BoxConstraints(
  minWidth: kMinInteractiveDimension,
  minHeight: kMinInteractiveDimension,
);

class VanepHomeTopBar extends StatelessWidget {
  const VanepHomeTopBar({
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    this.onMessagesTapped,
    super.key,
  });

  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;
  final VoidCallback? onMessagesTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: l10n.homeMenuTooltip,
          onPressed: onMenuTapped,
          padding: EdgeInsets.zero,
          constraints: _edgeAlignedTapTarget,
          alignment: Alignment.centerLeft,
          icon: const Icon(Icons.menu_rounded, color: VanepColors.textPrimary),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMessagesTapped != null)
              IconButton(
                tooltip: l10n.conversationsInboxTitle,
                onPressed: onMessagesTapped,
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: VanepColors.textPrimary,
                ),
              ),
            IconButton(
              tooltip: l10n.navNotifications,
              onPressed: onNotificationsTapped,
              padding: EdgeInsets.zero,
              constraints: _edgeAlignedTapTarget,
              alignment: Alignment.centerRight,
              icon: const Icon(
                Icons.notifications_outlined,
                color: VanepColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
