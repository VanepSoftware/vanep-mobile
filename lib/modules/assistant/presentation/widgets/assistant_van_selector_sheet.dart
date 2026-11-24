import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

Future<void> showAssistantVanSelectorSheet(
  BuildContext context, {
  required List<AssistantVan> vans,
  required AssistantVan? selectedVan,
  required ValueChanged<AssistantVan> onSelectVan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.card,
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
                color: context.palette.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(l10n.assistantSelectVanTitle, style: context.typography.heading),
          const SizedBox(height: 4),
          Text(
            l10n.assistantSelectVanSubtitle,
            style: context.typography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          if (vans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l10n.assistantNoVansLinked,
                  style: context.typography.body.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: vans.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: context.palette.divider),
                itemBuilder: (context, index) {
                  final van = vans[index];
                  final isSelected = van == selectedVan;

                  final shiftText = formatApiSchoolShift(l10n, van.shift);
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
                            ? context.palette.actionSurface
                            : context.palette.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.airport_shuttle_rounded,
                        color: isSelected
                            ? context.palette.action
                            : context.palette.textSecondary,
                      ),
                    ),
                    title: Text(
                      '${van.model} (${van.plate})',
                      style: context.typography.body.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: context.typography.cardSubtitle,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: context.palette.action,
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
