import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({this.title, super.key});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return AppBar(
      backgroundColor: VanepColors.card,
      foregroundColor: VanepColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: title == null
          ? null
          : Text(title, style: VanepTypography.cardTitle),
    );
  }
}

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    required this.title,
    required this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            AuthIconBadge(icon: icon, size: 56),
            const SizedBox(height: 20),
          ],
          Text(title, style: VanepTypography.loginTitle),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: VanepTypography.cardSubtitle.copyWith(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthIconBadge extends StatelessWidget {
  const AuthIconBadge({required this.icon, this.size = 48, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: VanepColors.action.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(icon, color: VanepColors.action, size: size * 0.48),
    );
  }
}

List<Widget> withSpacing(List<Widget> children, double spacing) {
  return [
    for (var index = 0; index < children.length; index++) ...[
      if (index > 0) SizedBox(height: spacing),
      children[index],
    ],
  ];
}

const double authFieldRowMinWidth = 340;

class AuthFieldRow extends StatelessWidget {
  const AuthFieldRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < authFieldRowMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: withSpacing(children, 20),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}

class AuthBottomBar extends StatelessWidget {
  const AuthBottomBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: VanepColors.card,
        border: Border(top: BorderSide(color: VanepColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: child,
        ),
      ),
    );
  }
}

class AuthOutlinedPanel extends StatelessWidget {
  const AuthOutlinedPanel({
    required this.child,
    this.onTap,
    this.highlighted = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? VanepColors.action.withValues(alpha: 0.04)
          : VanepColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted ? VanepColors.action : VanepColors.cardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
