import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';

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

class AvatarTone {
  const AvatarTone(this.background, this.foreground);

  final Color background;

  final Color foreground;
}

const avatarTones = [
  AvatarTone(VanepColors.actionSurface, VanepColors.action),
  AvatarTone(VanepColors.warningSurface, VanepColors.warning),
  AvatarTone(Color(0x1A1E8E5A), VanepColors.success),
];

AvatarTone avatarToneFor(String name) {
  final seed = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return avatarTones[seed % avatarTones.length];
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    required this.name,
    this.size = 40,
    this.dimmed = false,
    super.key,
  });

  final String name;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tone = avatarToneFor(name);
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: VanepAvatar(
        size: size,
        initials: initialsOf(name),
        backgroundColor: tone.background,
        foregroundColor: tone.foreground,
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.names,
    this.dimmedNames = const {},
    this.size = 36,
    super.key,
  });

  final List<String> names;
  final Set<String> dimmedNames;
  final double size;

  @override
  Widget build(BuildContext context) {
    final step = size * 0.62;
    return SizedBox(
      width: size + step * (names.length - 1),
      height: size,
      child: Stack(
        children: [
          for (final (index, name) in names.indexed)
            Positioned(
              left: step * index,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: VanepColors.card,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: PersonAvatar(
                    name: name,
                    size: size - 3,
                    dimmed: dimmedNames.contains(name),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
          Expanded(child: Text(title, style: VanepTypography.sectionTitle)),
          if (label != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(label, style: VanepTypography.linkAction),
            ),
        ],
      ),
    );
  }
}

class HomeIconBubble extends StatelessWidget {
  const HomeIconBubble({
    required this.icon,
    this.background = VanepColors.actionSurface,
    this.foreground = VanepColors.action,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.5, color: foreground),
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
                        Text(title, style: VanepTypography.cardTitle),
                        if (subtitleText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleText,
                            style: VanepTypography.cardSubtitle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      (onTap == null
                          ? const SizedBox.shrink()
                          : const Icon(
                              Icons.chevron_right,
                              color: VanepColors.textMuted,
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
      color: VanepColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: const BorderSide(color: VanepColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: VanepColors.divider,
              ),
            row,
          ],
        ],
      ),
    );
  }
}

class HomeBadgeText extends StatelessWidget {
  const HomeBadgeText({
    required this.text,
    this.color = VanepColors.warning,
    super.key,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: VanepTypography.cardSubtitle.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
