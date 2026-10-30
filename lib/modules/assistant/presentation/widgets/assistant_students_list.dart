import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_students_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const studentRowMinHeight = 64.0;

// TODO(VAN-73): rows do nothing until the student details screen (VAN-74)
// exists. Replace the call site and delete this function.
void openStudentDetailsLater() {}

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

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: student.isAbsentToday
          ? '${student.name}, $stop, ${l10n.assistantStudentsAbsentToday}'
          : '${student.name}, $stop',
      child: InkWell(
        onTap: openStudentDetailsLater,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: studentRowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                VanepAvatar(
                  size: 40,
                  initials: assistantInitialsOf(student.name).padRight(1).substring(0, 1),
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
                if (student.isAbsentToday) ...[
                  const SizedBox(width: 8),
                  Text(
                    l10n.assistantStudentsAbsentToday,
                    style: VanepTypography.ratingLabel.copyWith(
                      color: VanepColors.warning,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: VanepColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
