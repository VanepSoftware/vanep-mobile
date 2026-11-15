import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VanepAppBar({this.title, this.caption, this.actions, super.key});

  final String? title;
  final String? caption;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return AppBar(
      backgroundColor: context.palette.card,
      foregroundColor: context.palette.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: title == null
          ? null
          : VanepAppBarTitle(title: title, caption: caption),
      actions: actions,
    );
  }
}

class VanepAppBarTitle extends StatelessWidget {
  const VanepAppBarTitle({required this.title, this.caption, super.key});

  final String title;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final caption = this.caption;
    final titleText = Text(title, style: context.typography.cardTitle);
    if (caption == null) return titleText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleText,
        const SizedBox(height: 1),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.cardSubtitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class VanepPageHeader extends StatelessWidget {
  const VanepPageHeader({
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
            VanepIconBadge(icon: icon, size: 56),
            const SizedBox(height: 20),
          ],
          Text(title, style: context.typography.loginTitle),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.typography.cardSubtitle.copyWith(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class VanepIconBadge extends StatelessWidget {
  const VanepIconBadge({required this.icon, this.size = 48, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.palette.action.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(icon, color: context.palette.action, size: size * 0.48),
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

const double vanepFieldRowMinWidth = 340;

class VanepFieldRow extends StatelessWidget {
  const VanepFieldRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < vanepFieldRowMinWidth) {
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

class VanepBottomBar extends StatelessWidget {
  const VanepBottomBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.card,
        border: Border(top: BorderSide(color: context.palette.cardBorder)),
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

class VanepOutlinedPanel extends StatelessWidget {
  const VanepOutlinedPanel({
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
          ? context.palette.action.withValues(alpha: 0.04)
          : context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted
              ? context.palette.action
              : context.palette.cardBorder,
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
