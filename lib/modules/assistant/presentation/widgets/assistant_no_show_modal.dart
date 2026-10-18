import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

Future<NoShowReason?> showAssistantNoShowModal(
  BuildContext context, {
  required String studentName,
}) {
  return showModalBottomSheet<NoShowReason>(
    context: context,
    backgroundColor: VanepColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: AssistantNoShowModal(
        studentName: studentName,
        onConfirm: (reason) => Navigator.of(sheetContext).pop(reason),
      ),
    ),
  );
}

class AssistantNoShowModal extends StatefulWidget {
  const AssistantNoShowModal({
    required this.studentName,
    required this.onConfirm,
    super.key,
  });

  final String studentName;

  final ValueChanged<NoShowReason> onConfirm;

  @override
  State<AssistantNoShowModal> createState() => _AssistantNoShowModalState();
}

class _AssistantNoShowModalState extends State<AssistantNoShowModal> {
  NoShowReason _selectedReason = NoShowReason.notifiedByGuardian;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final reasons = [
      (NoShowReason.notifiedByGuardian, l10n.assistantNoShowReasonNotified),
      (NoShowReason.notAtLocation, l10n.assistantNoShowReasonNotAtLocation),
      (NoShowReason.other, l10n.assistantNoShowReasonOther),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            l10n.assistantNoShowModalTitle,
            style: VanepTypography.heading,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.studentName} — ${l10n.assistantNoShowModalSubtitle}',
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          for (final (reason, label) in reasons)
            InkWell(
              onTap: () => setState(() => _selectedReason = reason),
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedReason == reason
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedReason == reason
                            ? VanepColors.action
                            : VanepColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: VanepTypography.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: ElevatedButton(
                onPressed: () => widget.onConfirm(_selectedReason),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VanepColors.danger,
                  foregroundColor: VanepColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.assistantNoShowConfirm,
                  style: VanepTypography.button,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
