import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

String assistantShiftLabel(AppLocalizations l10n, String? shift) {
  return switch (shift?.toUpperCase()) {
    'MORNING' => l10n.assistantShiftMorning,
    'AFTERNOON' => l10n.assistantShiftAfternoon,
    'NIGHT' => l10n.assistantShiftNight,
    _ => shift ?? '',
  };
}

Future<void> showAssistantVanSelectorSheet(
  BuildContext context, {
  required List<AssistantVan> vans,
  required AssistantVan? selectedVan,
  required ValueChanged<AssistantVan> onSelectVan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: VanepColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: AssistantVanSelectorSheet(
        vans: vans,
        selectedVan: selectedVan,
        onSelectVan: (van) {
          onSelectVan(van);
          Navigator.of(sheetContext).pop();
        },
      ),
    ),
  );
}

class AssistantVanSelectorSheet extends StatelessWidget {
  const AssistantVanSelectorSheet({
    required this.vans,
    required this.selectedVan,
    required this.onSelectVan,
    super.key,
  });

  final List<AssistantVan> vans;

  final AssistantVan? selectedVan;

  final ValueChanged<AssistantVan> onSelectVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: VanepColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l10n.assistantSelectVanTitle,
            style: VanepTypography.heading,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.assistantSelectVanSubtitle,
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          if (vans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l10n.assistantNoVansLinked,
                  style: VanepTypography.body.copyWith(
                    color: VanepColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: vans.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: VanepColors.divider,
                ),
                itemBuilder: (context, index) {
                  final van = vans[index];
                  final isSelected = van.token == selectedVan?.token;

                  final shiftText = assistantShiftLabel(l10n, van.shift);
                  final subtitle = shiftText.isEmpty
                      ? van.driverName
                      : '${van.driverName} • $shiftText';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VanepColors.actionSurface
                            : VanepColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.airport_shuttle_rounded,
                        color: isSelected
                            ? VanepColors.action
                            : VanepColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      '${van.model} (${van.plate})',
                      style: VanepTypography.body.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: VanepColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: VanepTypography.cardSubtitle,
                    ),
                    trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: VanepColors.action,
                        )
                      : null,
                    onTap: () => onSelectVan(van),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
