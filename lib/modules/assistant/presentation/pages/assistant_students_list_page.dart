import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_checklist_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_no_show_modal.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_student_card.dart';

class AssistantStudentsListPage extends StatelessWidget {
  const AssistantStudentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AssistantChecklistCubit, AssistantChecklistState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isLinkRevoked) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_off_rounded,
                    size: 52,
                    color: context.palette.danger,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.assistantLinkRevokedTitle,
                    textAlign: TextAlign.center,
                    style: context.typography.heading,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.assistantLinkRevokedMessage,
                    textAlign: TextAlign.center,
                    style: context.typography.body.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.failure != null) {
          return AssistantChecklistErrorView(state: state);
        }

        final cubit = context.read<AssistantChecklistCubit>();
        final students = state.filteredStudents;

        final filters = <(BoardingStatus?, String)>[
          (null, l10n.assistantFilterAll),
          (BoardingStatus.pending, l10n.assistantStatusPending),
          (BoardingStatus.boarded, l10n.assistantStatusBoarded),
          (BoardingStatus.droppedOff, l10n.assistantStatusDroppedOff),
          (BoardingStatus.noShow, l10n.assistantStatusNoShow),
        ];

        return Column(
          children: [
            Container(
              color: context.palette.card,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: cubit.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: l10n.assistantStudentsSearchHint,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.palette.textSecondary,
                      ),
                      filled: true,
                      fillColor: context.palette.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final (status, label) in filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: state.statusFilter == status,
                              onSelected: (_) =>
                                  cubit.updateStatusFilter(status),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.palette.divider),
            Expanded(
              child: students.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.assistantStudentsEmpty,
                          textAlign: TextAlign.center,
                          style: context.typography.body.copyWith(
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return AssistantStudentCard(
                          item: student,
                          showSelection: false,
                          onConfirmBoarding: () =>
                              cubit.confirmBoarding(student.studentToken),
                          onMarkNoShow: () async {
                            final reason = await showAssistantNoShowModal(
                              context,
                              studentName: student.studentName,
                            );
                            if (reason != null && context.mounted) {
                              await cubit.markNoShow(
                                student.studentToken,
                                reason,
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
