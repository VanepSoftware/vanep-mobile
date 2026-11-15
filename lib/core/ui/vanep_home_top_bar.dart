import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
          icon: Icon(Icons.menu_rounded, color: context.palette.textPrimary),
        ),
        IconButton(
          tooltip: l10n.navNotifications,
          onPressed: onNotificationsTapped,
          padding: EdgeInsets.zero,
          constraints: _edgeAlignedTapTarget,
          alignment: Alignment.centerRight,
          icon: Icon(
            Icons.notifications_outlined,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
