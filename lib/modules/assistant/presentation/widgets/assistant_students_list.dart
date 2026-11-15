import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_students_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const studentRowMinHeight = 64.0;

class AssistantStudentRow extends StatelessWidget {
  const AssistantStudentRow({required this.student, super.key});

  final AssistantStudentSummary student;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (surface, accent) = studentAvatarToneOf(student.token);
    final stop = l10n.assistantStudentsStop(
      student.stopNumber,
      student.placeName,
    );
    final tags = [
      if (!student.hasFamilyInApp) l10n.assistantStudentsWithoutFamily,
      if (student.isAbsentToday) l10n.assistantStudentsAbsentToday,
    ];

    // TODO(VAN-74): the row becomes tappable (InkWell, button semantics and a
    // chevron) when the student details screen exists.
    return Semantics(
      excludeSemantics: true,
      label: [student.name, stop, ...tags].join(', '),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: studentRowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              VanepAvatar(
                size: 40,
                initials: assistantInitialOf(student.name),
                backgroundColor: surface,
                foregroundColor: accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: VanepTypography.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      stop,
                      style: VanepTypography.cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!student.hasFamilyInApp) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.assistantStudentsWithoutFamily,
                  style: VanepTypography.ratingLabel.copyWith(
                    color: VanepColors.textMuted,
                  ),
                ),
              ],
              if (student.isAbsentToday) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.assistantStudentsAbsentToday,
                  style: VanepTypography.ratingLabel.copyWith(
                    color: VanepColors.warning,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
