import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';

class VanepSegment<T> {
  const VanepSegment({required this.value, required this.label, this.count});

  final T value;

  final String label;

  final int? count;
}

class VanepSegmentedControl<T> extends StatelessWidget {
  const VanepSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<VanepSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: VanepColors.divider,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
      ),
      child: Row(
        children: [
          for (final (index, segment) in segments.indexed) ...[
            if (index > 0) const SizedBox(width: 4),
            Expanded(
              child: VanepSegmentButton(
                label: segment.label,
                count: segment.count,
                isSelected: segment.value == selected,
                onTap: () => onSelected(segment.value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VanepSegmentButton extends StatelessWidget {
  const VanepSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    super.key,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? VanepColors.card : Colors.transparent,
        elevation: isSelected ? 1 : 0,
        shadowColor: VanepColors.textPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? VanepColors.textPrimary
                          : VanepColors.textSecondary,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? VanepColors.action
                          : VanepColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
