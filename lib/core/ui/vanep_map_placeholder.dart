import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const double vanepMapPlaceholderHeight = 168;

// TODO(VAN-39): replace with a real map once the backend stores coordinates
// on `address` and `school`. Until then nothing drawn here is a real position.
// Used by the dependent School and Pickup editors.
class VanepMapPlaceholder extends StatelessWidget {
  const VanepMapPlaceholder({
    required this.pinIcon,
    this.label,
    this.actionLabel,
    super.key,
  });

  final IconData pinIcon;
  final String? label;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = this.label;
    final actionLabel = this.actionLabel;

    return SizedBox(
      height: vanepMapPlaceholderHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
            border: Border.all(color: context.palette.cardBorder),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                image: true,
                label: l10n.mapPlaceholderSemantics,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: VanepMapStreetsPainter(context.palette),
                        ),
                        Center(child: VanepMapPin(icon: pinIcon)),
                        if (label != null)
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: VanepMapLabel(text: label),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (actionLabel != null)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: VanepMapAdjustChip(label: actionLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VanepMapPin extends StatelessWidget {
  const VanepMapPin({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.palette.action,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.palette.action.withValues(alpha: 0.18),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: VanepColors.onBrand),
    );
  }
}

class VanepMapLabel extends StatelessWidget {
  const VanepMapLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.cardTitle.copyWith(fontSize: 13),
      ),
    );
  }
}

class VanepMapAdjustChip extends StatelessWidget {
  const VanepMapAdjustChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.card,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {},
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_with,
                size: 18,
                color: context.palette.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.typography.cardTitle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VanepMapStreetsPainter extends CustomPainter {
  const VanepMapStreetsPainter(this.palette);

  final VanepPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.skeletonBase);
    canvas.drawRect(
      Rect.fromLTWH(width * 0.62, height * 0.08, width * 0.22, height * 0.3),
      Paint()..color = palette.avatarBlueSurface,
    );
    final street = Paint()..color = palette.card;
    canvas
      ..drawRect(Rect.fromLTWH(width * 0.3, 0, width * 0.07, height), street)
      ..drawRect(Rect.fromLTWH(0, height * 0.56, width, height * 0.07), street);
    final avenue = Paint()
      ..color = palette.card
      ..strokeWidth = 10;
    canvas.drawLine(
      Offset(width * 0.45, height),
      Offset(width, height * 0.2),
      avenue,
    );
  }

  @override
  bool shouldRepaint(VanepMapStreetsPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
