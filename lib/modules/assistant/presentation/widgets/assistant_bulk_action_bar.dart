import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class AssistantBulkActionBar extends StatelessWidget {
  const AssistantBulkActionBar({
    required this.selectedCount,
    required this.onConfirmBulkDropOff,
    this.isUpdating = false,
    super.key,
  });

  final int selectedCount;

  final VoidCallback onConfirmBulkDropOff;

  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    if (selectedCount <= 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: VanepColors.card,
        border: Border(
          top: BorderSide(color: VanepColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: ElevatedButton.icon(
              onPressed: isUpdating ? null : onConfirmBulkDropOff,
              style: ElevatedButton.styleFrom(
                backgroundColor: VanepColors.success,
                foregroundColor: VanepColors.onBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.done_all_rounded, size: 20),
              label: Text(
                l10n.assistantBulkDropOff(selectedCount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
