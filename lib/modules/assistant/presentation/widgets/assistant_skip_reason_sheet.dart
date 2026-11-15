import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class SkipReasons {
  const SkipReasons({required this.reasons, required this.notes});

  final Map<String, NoShowReason> reasons;
  final Map<String, String> notes;
}

Future<SkipReasons?> showSkipReasonSheet(
  BuildContext context, {
  required List<AssistantRoutePassenger> passengers,
  required NoShowReason defaultReason,
  required bool isBoarding,
}) {
  return showModalBottomSheet<SkipReasons>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.card,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: AssistantSkipReasonSheet(
        passengers: passengers,
        defaultReason: defaultReason,
        isBoarding: isBoarding,
      ),
    ),
  );
}

class AssistantSkipReasonSheet extends StatefulWidget {
  const AssistantSkipReasonSheet({
    required this.passengers,
    required this.defaultReason,
    required this.isBoarding,
    super.key,
  });

  final List<AssistantRoutePassenger> passengers;
  final NoShowReason defaultReason;
  final bool isBoarding;

  @override
  State<AssistantSkipReasonSheet> createState() =>
      _AssistantSkipReasonSheetState();
}

class _AssistantSkipReasonSheetState extends State<AssistantSkipReasonSheet> {
  late final Map<String, NoShowReason> reasons = {
    for (final passenger in widget.passengers)
      passenger.token: widget.defaultReason,
  };
  late final Map<String, TextEditingController> notes = {
    for (final passenger in widget.passengers)
      passenger.token: TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in notes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void chooseReason(String token, NoShowReason reason) {
    setState(() => reasons[token] = reason);
  }

  SkipReasons collectReasons() => SkipReasons(
    reasons: {...reasons},
    notes: {
      for (final MapEntry(key: token, value: reason) in reasons.entries)
        if (reason == NoShowReason.other) token: notes[token]!.text,
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isBoarding
                  ? l10n.assistantSkipReasonTitleBoarding
                  : l10n.assistantSkipReasonTitleDropOff,
              style: typography.sectionTitle,
            ),
            for (final passenger in widget.passengers) ...[
              const SizedBox(height: assistantHomeSectionSpacing),
              Text(passenger.name, style: typography.cardTitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final reason in NoShowReason.values)
                    VanepChoiceChip(
                      label: noShowReasonLabel(l10n, reason),
                      isSelected: reasons[passenger.token] == reason,
                      onTap: () => chooseReason(passenger.token, reason),
                    ),
                ],
              ),
              if (reasons[passenger.token] == NoShowReason.other) ...[
                const SizedBox(height: 8),
                VanepTextField(
                  controller: notes[passenger.token]!,
                  label: l10n.assistantSkipReasonOtherLabel,
                  onChanged: (_) {},
                ),
              ],
            ],
            const SizedBox(height: assistantHomeSectionSpacing),
            VanepPrimaryButton(
              label: l10n.assistantSkipReasonConfirm,
              onPressed: () => Navigator.of(context).pop(collectReasons()),
            ),
          ],
        ),
      ),
    );
  }
}
