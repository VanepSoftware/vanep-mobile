import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_search_field.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_students_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_student_detail_page.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_students_list.dart';

const assistantStudentsPagePadding = EdgeInsets.fromLTRB(20, 24, 20, 24);

class AssistantStudentsPage extends StatelessWidget {
  const AssistantStudentsPage({super.key});

  static Widget withCubit() {
    return BlocProvider<AssistantStudentsCubit>(
      create: (_) => getIt<AssistantStudentsCubit>()..loadStudents(),
      child: const AssistantStudentsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: BlocBuilder<AssistantStudentsCubit, AssistantStudentsState>(
          builder: (context, state) => AssistantStudentsBody(state: state),
        ),
      ),
    );
  }
}

class AssistantStudentsBody extends StatelessWidget {
  const AssistantStudentsBody({required this.state, super.key});

  final AssistantStudentsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantStudentsCubit>();
    final rosters = state.overview?.rosters ?? const [];
    final roster = state.selectedRoster;

    return ListView(
      padding: assistantStudentsPagePadding,
      children: [
        Text(l10n.assistantStudentsTitle, style: context.typography.pageTitle),
        const SizedBox(height: 4),
        if (roster != null)
          Text(
            l10n.assistantStudentsSubtitle(
              firstNameOf(roster.van.driverName),
              assistantVansShiftLabel(l10n, roster.van.shift),
              roster.students.length,
            ),
            style: context.typography.cardSubtitle,
          ),
        const SizedBox(height: 20),
        switch (state.status) {
          AssistantStudentsStatus.loading => const AssistantStudentsSkeleton(),
          AssistantStudentsStatus.loadFailed => VanepErrorView(
            message: assistantFailureMessage(l10n, state.failure!),
            retryLabel: l10n.assistantVansRetry,
            onRetry: cubit.loadStudents,
          ),
          AssistantStudentsStatus.ready when roster == null => Text(
            l10n.assistantVansEmpty,
            textAlign: TextAlign.center,
            style: context.typography.cardSubtitle,
          ),
          AssistantStudentsStatus.ready => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rosters.length > 1) ...[
                VanepChoiceChips<int>(
                  choices: [
                    for (final (index, item) in rosters.indexed)
                      VanepChoice(
                        value: index,
                        label: assistantRosterTabLabel(l10n, item.van),
                      ),
                  ],
                  selected: state.selectedRosterIndex,
                  onSelected: cubit.selectRoster,
                ),
                const SizedBox(height: 16),
              ],
              VanepSearchField(
                key: ValueKey(state.selectedRosterIndex),
                hintText: l10n.assistantStudentsSearchHint,
                onChanged: cubit.search,
              ),
              const SizedBox(height: 8),
              if (state.visibleStudents.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    state.query.isEmpty
                        ? l10n.assistantStudentsEmpty
                        : l10n.assistantStudentsNoResults,
                    textAlign: TextAlign.center,
                    style: context.typography.cardSubtitle,
                  ),
                )
              else
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.palette.card,
                    borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
                    border: Border.all(color: context.palette.cardBorder),
                  ),
                  child: Column(
                    children: [
                      for (final (index, student)
                          in state.visibleStudents.indexed) ...[
                        if (index > 0)
                          Divider(height: 1, color: context.palette.divider),
                        AssistantStudentRow(
                          student: student,
                          onTap: () => Navigator.of(context).push(
                            AssistantStudentDetailPage.route(
                              student.token,
                              today: student.isAbsentToday
                                  ? const AssistantStudentToday(
                                      status: BoardingStatus.notGoingToday,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        },
      ],
    );
  }
}

class AssistantStudentsSkeleton extends StatelessWidget {
  const AssistantStudentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: 6,
      spacing: 12,
      buildPlaceholder: (_) => const Row(
        children: [
          Bone.circle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2, fontSize: 16),
                SizedBox(height: 4),
                Bone.text(words: 3, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
