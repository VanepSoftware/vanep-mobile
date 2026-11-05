import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';

const shortcutsPerRow = 3;

IconData shortcutIcon(HomeShortcut shortcut) {
  return switch (shortcut) {
    HomeShortcut.reportAbsence => Icons.event_busy_outlined,
    HomeShortcut.seeOnMap => Icons.map_outlined,
    HomeShortcut.adjustStop => Icons.edit_location_alt_outlined,
    HomeShortcut.payments => Icons.payments_outlined,
    HomeShortcut.proposals => Icons.request_quote_outlined,
    HomeShortcut.contracts => Icons.contact_page_outlined,
  };
}

class HomeShortcutsGrid extends StatelessWidget {
  const HomeShortcutsGrid({
    required this.enabledShortcuts,
    required this.onShortcutTapped,
    super.key,
  });

  final Set<HomeShortcut> enabledShortcuts;
  final ValueChanged<HomeShortcut> onShortcutTapped;

  @override
  Widget build(BuildContext context) {
    const shortcuts = HomeShortcut.values;
    return Column(
      children: [
        for (
          var rowStart = 0;
          rowStart < shortcuts.length;
          rowStart += shortcutsPerRow
        ) ...[
          if (rowStart > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < shortcutsPerRow; column++) ...[
                  if (column > 0) const SizedBox(width: 10),
                  Expanded(
                    child: HomeShortcutTile(
                      shortcut: shortcuts[rowStart + column],
                      enabled: enabledShortcuts.contains(
                        shortcuts[rowStart + column],
                      ),
                      onTap: () =>
                          onShortcutTapped(shortcuts[rowStart + column]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class HomeShortcutTile extends StatelessWidget {
  const HomeShortcutTile({
    required this.shortcut,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final HomeShortcut shortcut;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final foreground = enabled
        ? VanepColors.textPrimary
        : VanepColors.textMuted;

    return Material(
      color: enabled ? VanepColors.card : VanepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: const BorderSide(color: VanepColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: enabled ? VanepColors.surface : VanepColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(shortcutIcon(shortcut), color: foreground),
              ),
              const SizedBox(height: 10),
              Text(
                formatShortcut(l10n, shortcut),
                textAlign: TextAlign.center,
                style: VanepTypography.cardSubtitle.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
