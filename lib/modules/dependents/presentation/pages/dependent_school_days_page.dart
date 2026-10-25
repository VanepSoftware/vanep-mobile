import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_editor_frame.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependents_list_card.dart';

Future<SchoolWeek?> openDependentSchoolDays(
  BuildContext context, {
  required Dependent dependent,
}) {
  return Navigator.of(context).push<SchoolWeek>(
    MaterialPageRoute<SchoolWeek>(
      builder: (_) => DependentSchoolDaysPage(dependent: dependent),
    ),
  );
}

class DependentSchoolDaysPage extends StatelessWidget {
  const DependentSchoolDaysPage({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          getIt<DependentSchoolDaysCubit>(param1: dependent.token)..load(),
      child: DependentEditorFrame(
        title: l10n.dependentRowSchoolDays,
        caption: dependentFirstName(dependent.name),
        body: const DependentSchoolDaysBody(),
        bottomBar:
            DependentEditorSaveBar<
              DependentSchoolDaysCubit,
              DependentSchoolDaysState
            >(
              label: l10n.dependentEditorSave,
              onSaved: (state) => Navigator.of(context).pop(state.week),
            ),
      ),
    );
  }
}

class DependentSchoolDaysBody extends StatelessWidget {
  const DependentSchoolDaysBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentSchoolDaysCubit>();

    return BlocConsumer<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      listenWhen: (previous, current) =>
          current.failure != previous.failure &&
          current.failure != null &&
          !current.hasLoadFailed,
      listener: (context, state) => VanepFeedback.showError(
        context,
        dependentFailureLabel(l10n, state.failure!),
      ),
      builder: (context, state) {
        if (state.isLoading) return const DependentSchoolDaysSkeleton();
        if (state.hasLoadFailed) {
          return VanepErrorView(
            message: l10n.dependentSchoolDaysLoadError,
            retryLabel: l10n.dependentsRetry,
            onRetry: cubit.load,
          );
        }
        return VanepSection(
          title: l10n.dependentSchoolDaysWeek,
          note: l10n.dependentSchoolDayCount(state.week.dayCount),
          child: DependentsListCard(
            rows: [
              for (final day in Weekday.values)
                DependentSchoolDayRow(
                  day: day,
                  shift: state.week.shiftOf(day),
                  enabled: !state.isSaving,
                  onToggle: (isOn) =>
                      isOn ? cubit.turnOn(day) : cubit.turnOff(day),
                  onShiftChanged: (shift) => cubit.changeShift(day, shift),
                ),
            ],
          ),
        );
      },
    );
  }
}

class DependentSchoolDayRow extends StatelessWidget {
  const DependentSchoolDayRow({
    required this.day,
    required this.shift,
    required this.enabled,
    required this.onToggle,
    required this.onShiftChanged,
    super.key,
  });

  final Weekday day;
  final SchoolShift? shift;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<SchoolShift> onShiftChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shift = this.shift;
    final dayName = weekdayLabel(l10n, day);
    final isOn = shift != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Semantics(
            label: l10n.dependentSchoolDayHasClass(dayName),
            child: Switch(
              value: isOn,
              activeTrackColor: VanepColors.action,
              onChanged: enabled ? onToggle : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dayName,
              style: VanepTypography.cardTitle.copyWith(
                fontSize: 15,
                fontWeight: isOn ? FontWeight.w700 : FontWeight.w600,
                color: isOn
                    ? VanepColors.textPrimary
                    : VanepColors.textSecondary,
              ),
            ),
          ),
          if (shift == null)
            Text(
              l10n.dependentSchoolDayOff,
              style: VanepTypography.cardSubtitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
          else
            DependentSchoolShiftPicker(
              dayName: dayName,
              shift: shift,
              enabled: enabled,
              onChanged: onShiftChanged,
            ),
        ],
      ),
    );
  }
}

class DependentSchoolShiftPicker extends StatelessWidget {
  const DependentSchoolShiftPicker({
    required this.dayName,
    required this.shift,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String dayName;
  final SchoolShift shift;
  final bool enabled;
  final ValueChanged<SchoolShift> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shiftName = schoolShiftLabel(l10n, shift);

    return PopupMenuButton<SchoolShift>(
      tooltip: l10n.dependentSchoolDayShift(dayName, shiftName),
      enabled: enabled,
      initialValue: shift,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final option in SchoolShift.values)
          PopupMenuItem(
            value: option,
            child: Text(schoolShiftLabel(l10n, option)),
          ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 14, right: 10),
        decoration: BoxDecoration(
          color: VanepColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: VanepColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shiftName,
              style: VanepTypography.ratingLabel.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more,
              size: 20,
              color: VanepColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class DependentSchoolDaysSkeleton extends StatelessWidget {
  const DependentSchoolDaysSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeleton(
      child: DependentsListCard(
        rows: [
          for (final _ in Weekday.values)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Row(
                children: [
                  Bone(width: 48, height: 28),
                  SizedBox(width: 12),
                  Expanded(child: Bone.text(words: 1, fontSize: 15)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
