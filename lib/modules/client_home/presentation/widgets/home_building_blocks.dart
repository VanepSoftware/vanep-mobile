import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const homeBlockSpacing = 24.0;

const homeCardSpacing = 10.0;

const brandCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [VanepColors.brandNavyBright, VanepColors.brandNavyDeep],
);

final onBrandMuted = VanepColors.onBrand.withValues(alpha: 0.75);

final onBrandFaint = VanepColors.onBrand.withValues(alpha: 0.14);

Future<void> openUnavailableFeature(BuildContext context, String title) {
  return openComingSoonPage(
    context,
    title: title,
    message: AppLocalizations.of(context)!.comingSoon,
  );
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.typography.sectionTitle)),
          if (label != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(label, style: context.typography.linkAction),
            ),
        ],
      ),
    );
  }
}

class HomeIconBubble extends StatelessWidget {
  const HomeIconBubble({
    required this.icon,
    this.background,
    this.foreground,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color? background;
  final Color? foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? context.palette.actionSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foreground ?? context.palette.action,
      ),
    );
  }
}

class HomeRowTile extends StatelessWidget {
  const HomeRowTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.footer,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: context.typography.cardTitle),
                        if (subtitleText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleText,
                            style: context.typography.cardSubtitle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      (onTap == null
                          ? const SizedBox.shrink()
                          : Icon(
                              Icons.chevron_right,
                              color: context.palette.textMuted,
                            )),
                ],
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

class HomeRowsCard extends StatelessWidget {
  const HomeRowsCard({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: BorderSide(color: context.palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              Divider(height: 1, thickness: 1, color: context.palette.divider),
            row,
          ],
        ],
      ),
    );
  }
}

class HomeBadgeText extends StatelessWidget {
  const HomeBadgeText({required this.text, this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.cardSubtitle.copyWith(
        color: color ?? context.palette.warning,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
