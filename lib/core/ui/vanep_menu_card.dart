import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_theme.dart';
import '../design_system/vanep_typography.dart';

class VanepMenuItem {
  const VanepMenuItem({
    required this.label,
    required this.icon,
    this.enabled = true,
    this.isDestructive = false,
    this.warningSubtitle,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool isDestructive;
  final String? warningSubtitle;
  final VoidCallback? onTap;
}

class VanepMenuCard extends StatelessWidget {
  const VanepMenuCard({required this.items, super.key});

  final List<VanepMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VanepColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: const BorderSide(color: VanepColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: VanepColors.divider,
              ),
            VanepMenuTile(item: items[index]),
          ],
        ],
      ),
    );
  }
}

class VanepMenuTile extends StatelessWidget {
  const VanepMenuTile({required this.item, super.key});

  final VanepMenuItem item;

  @override
  Widget build(BuildContext context) {
    final enabled = item.enabled;
    final foreground = !enabled
        ? VanepColors.textMuted
        : item.isDestructive
        ? VanepColors.danger
        : VanepColors.textPrimary;
    final iconColor = !enabled
        ? VanepColors.textMuted
        : item.isDestructive
        ? VanepColors.danger
        : VanepColors.textSecondary;
    final iconBackground = item.isDestructive && enabled
        ? VanepColors.danger.withValues(alpha: 0.10)
        : VanepColors.surface;
    final warningSubtitle = item.warningSubtitle;

    return InkWell(
      onTap: enabled ? item.onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: VanepTypography.cardTitle.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (warningSubtitle != null) ...[
                      const SizedBox(height: 3),
                      VanepMenuWarningSubtitle(text: warningSubtitle),
                    ],
                  ],
                ),
              ),
              if (!item.isDestructive)
                Icon(
                  Icons.chevron_right,
                  color: enabled ? VanepColors.textMuted : VanepColors.divider,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VanepMenuWarningSubtitle extends StatelessWidget {
  const VanepMenuWarningSubtitle({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 13, color: VanepColors.warning),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: VanepTypography.cardSubtitle.copyWith(
              color: VanepColors.warning,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
