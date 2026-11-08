import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/formatters/schedule_labels.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_filter_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/van_student_list.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/formatters/van_student_labels.dart';

class VanStudentsProgressCard extends StatelessWidget {
  const VanStudentsProgressCard({
    required this.progress,
    required this.isSharing,
    required this.onShareGroupLink,
    super.key,
  });

  final FamilyProgress progress;
  final bool isSharing;
  final VoidCallback onShareGroupLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l10n.vanStudentsProgressTitle(
                    progress.withFamily,
                    progress.total,
                  ),
                  style: VanepTypography.cardTitle,
                ),
              ),
              Text(
                l10n.vanStudentsProgressPercent(progress.percent),
                style: VanepTypography.cardSubtitle,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 8,
              color: VanepColors.action,
              backgroundColor: VanepColors.divider,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.vanStudentsProgressHint,
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 12),
          VanepSecondaryButton(
            label: l10n.vanStudentsShareGroupLink,
            icon: Icons.share_outlined,
            isLoading: isSharing,
            onPressed: onShareGroupLink,
          ),
        ],
      ),
    );
  }
}

class FamilyMatchCard extends StatelessWidget {
  const FamilyMatchCard({
    required this.student,
    required this.match,
    required this.isBusy,
    required this.onDismiss,
    required this.onConfirm,
    super.key,
  });

  final DriverStudent student;
  final FamilyMatch match;
  final bool isBusy;
  final VoidCallback onDismiss;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VanepInitialAvatar(
                name: match.dependentName,
                seed: student.token,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      familyMatchTitle(l10n, student),
                      style: VanepTypography.cardTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      familyMatchBody(l10n, match),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.vanStudentsMatchDismiss,
                  onPressed: isBusy ? null : onDismiss,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VanepPrimaryButton(
                  label: l10n.vanStudentsMatchConfirm,
                  isLoading: isBusy,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudentFamilyFilterControl extends StatelessWidget {
  const StudentFamilyFilterControl({
    required this.selected,
    required this.counts,
    required this.onSelected,
    super.key,
  });

  final StudentFamilyFilter selected;
  final Map<StudentFamilyFilter, int> counts;
  final ValueChanged<StudentFamilyFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.vanStudentsFilterLabel,
      container: true,
      child: VanepSegmentedControl<StudentFamilyFilter>(
        segments: [
          for (final filter in StudentFamilyFilter.values)
            VanepSegment(
              value: filter,
              label: familyFilterLabel(l10n, filter),
              count: counts[filter] ?? 0,
            ),
        ],
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

class StudentShiftChips extends StatelessWidget {
  const StudentShiftChips({
    required this.shifts,
    required this.enabled,
    required this.onToggled,
    super.key,
  });

  final List<OperationShift> shifts;
  final Set<OperationShift> enabled;
  final ValueChanged<OperationShift> onToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.vanStudentsShiftFilterLabel,
      container: true,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final shift in shifts)
            VanepFilterChip(
              label: operationShiftLabel(l10n, shift),
              isSelected: enabled.contains(shift),
              onTap: () => onToggled(shift),
            ),
        ],
      ),
    );
  }
}

class VanStudentActions {
  const VanStudentActions({
    required this.onInvite,
    required this.onConfirmFamily,
  });

  final ValueChanged<DriverStudent> onInvite;
  final ValueChanged<DriverStudent> onConfirmFamily;
}

class VanStudentsListCard extends StatelessWidget {
  const VanStudentsListCard({
    required this.students,
    required this.now,
    required this.isBusy,
    required this.actions,
    super.key,
  });

  final List<DriverStudent> students;
  final DateTime now;
  final bool Function(String studentToken) isBusy;
  final VanStudentActions actions;

  @override
  Widget build(BuildContext context) {
    return VanepCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, student) in students.indexed) ...[
            if (index > 0) const Divider(height: 1, color: VanepColors.divider),
            VanStudentRow(
              student: student,
              now: now,
              isBusy: isBusy(student.token),
              actions: actions,
            ),
          ],
        ],
      ),
    );
  }
}

class VanStudentRow extends StatelessWidget {
  const VanStudentRow({
    required this.student,
    required this.now,
    required this.isBusy,
    required this.actions,
    super.key,
  });

  final DriverStudent student;
  final DateTime now;
  final bool isBusy;
  final VanStudentActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isJoined = student.familyStatus == FamilyStatus.familyJoined;
    final subtitleStyle = isJoined
        ? VanepTypography.cardSubtitle.copyWith(
            color: VanepColors.action,
            fontWeight: FontWeight.w600,
          )
        : VanepTypography.cardSubtitle;

    return InkWell(
      onTap: isJoined && !isBusy
          ? () => actions.onConfirmFamily(student)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              VanepInitialAvatar(name: student.name, seed: student.token),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: VanepTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      studentRowSubtitle(l10n, student, now),
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ...switch (student.familyStatus) {
                FamilyStatus.notInvited => [
                  VanepSecondaryButton(
                    compact: true,
                    label: l10n.vanStudentsInvite,
                    icon: Icons.share_outlined,
                    isLoading: isBusy,
                    onPressed: () => actions.onInvite(student),
                  ),
                ],
                FamilyStatus.invited => [
                  VanepSecondaryButton(
                    compact: true,
                    label: l10n.vanStudentsResend,
                    isLoading: isBusy,
                    onPressed: () => actions.onInvite(student),
                  ),
                ],
                FamilyStatus.familyJoined => [
                  const Icon(Icons.chevron_right, color: VanepColors.textMuted),
                ],
                FamilyStatus.withFamily => const <Widget>[],
              },
            ],
          ),
        ),
      ),
    );
  }
}
