import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/school_week_bar.dart';

Color schoolWeekSegmentColor(SchoolWeekSegment segment) {
  return switch (segment) {
    SchoolWeekSegment.none => VanepColors.scheduleEmpty,
    SchoolWeekSegment.partTime => VanepColors.schedulePartTime,
    SchoolWeekSegment.fullTime => VanepColors.scheduleFullTime,
  };
}

class DependentSchoolWeekBar extends StatelessWidget {
  const DependentSchoolWeekBar({required this.week, super.key});

  final SchoolWeek week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final segments = describeSchoolWeekBar(week);

    return ExcludeSemantics(
      child: Row(
        children: [
          for (final day in Weekday.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: schoolWeekSegmentColor(segments[day.index]),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekdayInitial(l10n, day),
                      style: VanepTypography.cardSubtitle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DependentSchoolWeekBarSkeleton extends StatelessWidget {
  const DependentSchoolWeekBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepSkeleton(child: Bone(height: 22, width: double.infinity));
  }
}
