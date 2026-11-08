import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepLinkButton extends StatelessWidget {
  const VanepLinkButton({
    required this.label,
    required this.onPressed,
    this.color = VanepColors.action,
    this.showsChevron = false,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool showsChevron;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon case final icon?) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: VanepTypography.linkAction.copyWith(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
          if (showsChevron) const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}
