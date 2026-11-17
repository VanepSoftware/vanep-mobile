import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';

class DriverHomeTokens {
  const DriverHomeTokens();

  static const Color brand = VanepColors.brandNavy;
  static const Color brandSheen = VanepColors.brandSheen;
  static const Color brandMeter = VanepColors.brandMeter;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4E5E7);
  static const Color textPrimary = Color(0xFF0B2038);
  static const Color textSecondary = Color(0xFF6B7A8C);
  static const Color textMuted = Color(0xFF9AA7B4);
  static const Color action = Color(0xFF0B6BD3);
  static const Color actionSoft = Color(0xFFE6F0FA);
  static const Color success = Color(0xFF187A4C);
  static const Color successSoft = Color(0xFFE3F3EA);
  static const Color warning = Color(0xFFB86B11);
  static const Color warningSoft = Color(0xFFFBF0DE);
  static const Color danger = Color(0xFFC43B2B);
  static const Color dangerSoft = Color(0xFFFBE9E7);
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
}

class DriverNavyCard extends StatelessWidget {
  const DriverNavyCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: DriverHomeTokens.brand,
      borderRadius: BorderRadius.circular(DriverHomeTokens.radiusLg),
      gradient: const RadialGradient(
        center: Alignment(0.85, -1.0),
        radius: 1.35,
        colors: [DriverHomeTokens.brandSheen, DriverHomeTokens.brand],
      ),
    ),
    child: child,
  );
}

class DriverSectionHeader extends StatelessWidget {
  const DriverSectionHeader({
    required this.title,
    this.trailingText,
    this.onTrailingTap,
    super.key,
  });

  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: DriverHomeTokens.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ),
      if (trailingText != null)
        onTrailingTap != null
            ? InkWell(
                onTap: onTrailingTap,
                borderRadius: BorderRadius.circular(DriverHomeTokens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DriverHomeTokens.action,
                    ),
                  ),
                ),
              )
            : Text(
                trailingText!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DriverHomeTokens.textSecondary,
                ),
              ),
    ],
  );
}

class DriverIconBubble extends StatelessWidget {
  const DriverIconBubble({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 38,
    this.borderRadius = 10,
    super.key,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Icon(icon, size: size * 0.52, color: iconColor),
  );
}

class DriverListCard extends StatelessWidget {
  const DriverListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: DriverHomeTokens.surface,
      borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
      border: Border.all(color: DriverHomeTokens.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
          children[index],
        ],
      ],
    ),
  );
}

class DriverListRow extends StatelessWidget {
  const DriverListRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DriverHomeTokens.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DriverHomeTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    ),
  );
}

class DriverStartRouteSlideButton extends StatefulWidget {
  const DriverStartRouteSlideButton({
    required this.label,
    required this.enabled,
    required this.onTrigger,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTrigger;

  @override
  State<DriverStartRouteSlideButton> createState() =>
      DriverStartRouteSlideButtonState();
}

class DriverStartRouteSlideButtonState
    extends State<DriverStartRouteSlideButton> {
  double progress = 0;
  bool dragging = false;

  void finishDrag() {
    final triggered = dragging && progress >= 0.7 && widget.enabled;
    setState(() {
      progress = 0;
      dragging = false;
    });
    if (triggered) {
      widget.onTrigger();
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const thumbSize = 48.0;
      const trackHeight = 60.0;
      const padding = 6.0;
      final maxSlide = (box.maxWidth - thumbSize - padding * 2).clamp(
        0.0,
        double.infinity,
      );
      return Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTrigger : null,
          onHorizontalDragStart: widget.enabled && maxSlide > 0
              ? (_) => setState(() => dragging = true)
              : null,
          onHorizontalDragUpdate: widget.enabled && maxSlide > 0
              ? (details) => setState(() {
                  progress = (progress + details.delta.dx / maxSlide).clamp(
                    0.0,
                    1.0,
                  );
                })
              : null,
          onHorizontalDragEnd: widget.enabled ? (_) => finishDrag() : null,
          onHorizontalDragCancel: () => setState(() {
            progress = 0;
            dragging = false;
          }),
          child: Container(
            height: trackHeight,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 44, right: 12),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: progress * maxSlide,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x38022856),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: DriverHomeTokens.brand,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
