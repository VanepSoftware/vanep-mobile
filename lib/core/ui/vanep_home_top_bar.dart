import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design_system/vanep_colors.dart';

const BoxConstraints _edgeAlignedTapTarget = BoxConstraints(
  minWidth: kMinInteractiveDimension,
  minHeight: kMinInteractiveDimension,
);

class VanepHomeTopBar extends StatelessWidget {
  const VanepHomeTopBar({
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    super.key,
  });

  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;

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
    );
  }
}
