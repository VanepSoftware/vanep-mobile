import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_bulk_action_bar.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_no_show_modal.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_student_card.dart';

class AssistantTodayRoutePage extends StatelessWidget {
  const AssistantTodayRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AssistantChecklistCubit, AssistantChecklistState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isLinkRevoked) {
          return _RevokedLinkView(
            title: l10n.assistantLinkRevokedTitle,
            message: l10n.assistantLinkRevokedMessage,
          );
        }

        if (state.stops.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.route_outlined,
                    size: 52,
                    color: VanepColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.assistantRouteEmpty,
                    textAlign: TextAlign.center,
                    style: VanepTypography.body.copyWith(
                      color: VanepColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final cubit = context.read<AssistantChecklistCubit>();
        final progress = state.totalCount > 0
            ? state.completedCount / state.totalCount
            : 0.0;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: VanepColors.card,
                border: Border(
                  bottom: BorderSide(color: VanepColors.divider),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.assistantRouteProgress(
                      state.completedCount,
                      state.totalCount,
                    ),
                    style: VanepTypography.sectionTitle,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: VanepColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        VanepColors.action,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.stops.length,
                itemBuilder: (context, index) {
                  final stop = state.stops[index];
                  return _StopSection(
                    stop: stop,
                    selectedTokens: state.selectedStudentTokens,
                    onSelectAllStop: () => cubit.selectAllAtStop(stop.id),
                    onToggleSelect: cubit.toggleStudentSelection,
                    onConfirmBoarding: cubit.confirmBoarding,
                    onMarkNoShow: (studentToken, studentName) async {
                      final reason = await showAssistantNoShowModal(
                        context,
                        studentName: studentName,
                      );
                      if (reason != null && context.mounted) {
                        await cubit.markNoShow(studentToken, reason);
                      }
                    },
                  );
                },
              ),
            ),
            AssistantBulkActionBar(
              selectedCount: state.selectedStudentTokens.length,
              isUpdating: state.isUpdating,
              onConfirmBulkDropOff: cubit.confirmBulkDropOff,
            ),
          ],
        );
      },
    );
  }
}

class _StopSection extends StatelessWidget {
  const _StopSection({
    required this.stop,
    required this.selectedTokens,
    required this.onSelectAllStop,
    required this.onToggleSelect,
    required this.onConfirmBoarding,
    required this.onMarkNoShow,
  });

  final AssistantTripStop stop;

  final Set<String> selectedTokens;

  final VoidCallback onSelectAllStop;

  final ValueChanged<String> onToggleSelect;

  final ValueChanged<String> onConfirmBoarding;

  final void Function(String studentToken, String studentName) onMarkNoShow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasEligibleStudents = stop.items.any(
      (s) =>
          s.status == BoardingStatus.boarded ||
          s.status == BoardingStatus.pending,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stop.isSchool
                      ? VanepColors.action
                      : VanepColors.brandNavy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: stop.isSchool
                    ? const Icon(
                        Icons.school_rounded,
                        size: 18,
                        color: VanepColors.onBrand,
                      )
                    : Text(
                        '${stop.order}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: VanepColors.onBrand,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.title,
                      style: VanepTypography.sectionTitle,
                    ),
                    Text(
                      stop.address,
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              if (stop.isSchool && hasEligibleStudents)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: TextButton.icon(
                    onPressed: onSelectAllStop,
                    icon: const Icon(Icons.select_all_rounded, size: 18),
                    label: Text(
                      l10n.assistantSelectAllStop,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final student in stop.items)
            AssistantStudentCard(
              item: student,
              showSelection: true,
              isSelected: selectedTokens.contains(student.studentToken),
              onToggleSelect: () => onToggleSelect(student.studentToken),
              onConfirmBoarding: () => onConfirmBoarding(student.studentToken),
              onMarkNoShow: () => onMarkNoShow(
                student.studentToken,
                student.studentName,
              ),
            ),
        ],
      ),
    );
  }
}

class _RevokedLinkView extends StatelessWidget {
  const _RevokedLinkView({
    required this.title,
    required this.message,
  });

  final String title;

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link_off_rounded,
              size: 52,
              color: VanepColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: VanepTypography.heading,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: VanepTypography.body.copyWith(
                color: VanepColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
