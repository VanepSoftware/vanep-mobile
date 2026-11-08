import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/share/text_sharer.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_state.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/formatters/van_student_labels.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/widgets/van_students_widgets.dart';

class VanStudentsPage extends StatelessWidget {
  const VanStudentsPage({
    required this.vanCaption,
    required this.sharer,
    required this.onAddStudent,
    this.clock = DateTime.now,
    super.key,
  });

  final String vanCaption;
  final TextSharer sharer;
  final Future<String?> Function() onAddStudent;
  final DateTime Function() clock;

  String shareTextOf(AppLocalizations l10n, VanStudentsShareRequest request) {
    final studentName = request.studentName;
    return studentName == null
        ? l10n.vanStudentsGroupShareText(request.inviteUrl)
        : l10n.vanStudentsInviteShareText(studentName, request.inviteUrl);
  }

  String noticeTextOf(AppLocalizations l10n, VanStudentsNotice notice) {
    return switch (notice) {
      VanStudentsMergedNotice(:final studentName) => l10n.vanStudentsMerged(
        studentName,
      ),
      VanStudentsDismissedNotice() => l10n.vanStudentsDismissed,
      VanStudentsActionFailedNotice(:final failure) =>
        driverStudentFailureMessage(l10n, failure),
    };
  }

  Future<void> addStudent(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanStudentsCubit>();
    final createdName = await onAddStudent();
    if (createdName == null || !context.mounted) return;
    VanepFeedback.showInfo(context, l10n.unlinkedPassengerCreated(createdName));
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanStudentsCubit>();

    return BlocListener<VanStudentsCubit, VanStudentsState>(
      listenWhen: (previous, current) =>
          current.shareRequest != previous.shareRequest ||
          current.notice != previous.notice,
      listener: (context, state) {
        final shareRequest = state.shareRequest;
        if (shareRequest != null) {
          sharer.shareText(shareTextOf(l10n, shareRequest));
          cubit.clearShareRequest();
        }
        final notice = state.notice;
        if (notice != null) {
          final text = noticeTextOf(l10n, notice);
          if (notice is VanStudentsActionFailedNotice) {
            VanepFeedback.showError(context, text);
          } else {
            VanepFeedback.showInfo(context, text);
          }
          cubit.clearNotice();
        }
      },
      child: BlocBuilder<VanStudentsCubit, VanStudentsState>(
        buildWhen: (previous, current) =>
            current.isSearching != previous.isSearching,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: VanepColors.surface,
            appBar: VanepAppBar(
              title: state.isSearching ? null : l10n.vanStudentsTitle,
              titleWidget: state.isSearching
                  ? VanStudentsSearchField(onChanged: cubit.changeQuery)
                  : null,
              caption: vanCaption,
              actions: [
                IconButton(
                  tooltip: state.isSearching
                      ? l10n.vanStudentsSearchClose
                      : l10n.vanStudentsSearchAction,
                  onPressed: state.isSearching
                      ? cubit.closeSearch
                      : cubit.openSearch,
                  icon: Icon(state.isSearching ? Icons.close : Icons.search),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => addStudent(context),
              backgroundColor: VanepColors.brandNavy,
              foregroundColor: VanepColors.onBrand,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.vanStudentsAdd),
            ),
            body: VanStudentsBody(
              clock: clock,
              onConfirmFamily: (student) => confirmFamily(context, student),
            ),
          );
        },
      ),
    );
  }

  Future<void> confirmFamily(
    BuildContext context,
    DriverStudent student,
  ) async {
    final match = student.familyMatch;
    if (match == null) return;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanStudentsCubit>();
    final confirmed = await showVanepConfirmDialog(
      context: context,
      title: l10n.vanStudentsMergeDialogTitle(match.dependentName),
      message: l10n.vanStudentsMergeDialogMessage,
      confirmLabel: l10n.vanStudentsMergeDialogConfirm,
      cancelLabel: l10n.vanStudentsMatchDismiss,
    );
    if (confirmed) await cubit.mergeFamily(student);
  }
}

class VanStudentsBody extends StatelessWidget {
  const VanStudentsBody({
    required this.clock,
    required this.onConfirmFamily,
    super.key,
  });

  final DateTime Function() clock;
  final ValueChanged<DriverStudent> onConfirmFamily;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanStudentsCubit>();

    return BlocBuilder<VanStudentsCubit, VanStudentsState>(
      builder: (context, state) {
        return switch (state.status) {
          VanStudentsStatus.loading => const Center(
            child: CircularProgressIndicator(color: VanepColors.action),
          ),
          VanStudentsStatus.loadFailed => VanepErrorView(
            message: l10n.vanStudentsLoadError,
            retryLabel: l10n.driversRetryButton,
            onRetry: cubit.load,
          ),
          VanStudentsStatus.loaded => RefreshIndicator(
            color: VanepColors.action,
            onRefresh: cubit.refresh,
            child: VanStudentsContent(
              state: state,
              now: clock(),
              onConfirmFamily: onConfirmFamily,
            ),
          ),
        };
      },
    );
  }
}

class VanStudentsContent extends StatelessWidget {
  const VanStudentsContent({
    required this.state,
    required this.now,
    required this.onConfirmFamily,
    super.key,
  });

  final VanStudentsState state;
  final DateTime now;
  final ValueChanged<DriverStudent> onConfirmFamily;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<VanStudentsCubit>();
    final progress = state.progress;
    final pendingMatch = state.pendingMatch;
    final match = pendingMatch?.familyMatch;
    final visible = state.visibleStudents;
    final shifts = state.shifts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        if (progress.total > 0) ...[
          VanStudentsProgressCard(
            progress: progress,
            isSharing: state.isSharingGroupLink,
            onShareGroupLink: cubit.shareParentsGroupLink,
          ),
          const SizedBox(height: 16),
        ],
        if (pendingMatch != null && match != null) ...[
          FamilyMatchCard(
            student: pendingMatch,
            match: match,
            isBusy: state.isBusy(pendingMatch.token),
            onDismiss: () => cubit.dismissFamilyMatch(pendingMatch),
            onConfirm: () => onConfirmFamily(pendingMatch),
          ),
          const SizedBox(height: 16),
        ],
        StudentFamilyFilterControl(
          selected: state.familyFilter,
          counts: state.counts,
          onSelected: cubit.selectFamilyFilter,
        ),
        if (shifts.isNotEmpty) ...[
          const SizedBox(height: 12),
          StudentShiftChips(
            shifts: shifts,
            enabled: state.enabledShifts,
            onToggled: cubit.toggleShift,
          ),
        ],
        const SizedBox(height: 16),
        if (visible.isEmpty)
          VanStudentsEmptyMessage(
            text: state.students.isEmpty
                ? l10n.vanStudentsEmpty
                : l10n.vanStudentsEmptyFiltered,
          )
        else
          VanStudentsListCard(
            students: visible,
            now: now,
            isBusy: state.isBusy,
            actions: VanStudentActions(
              onInvite: cubit.inviteFamily,
              onConfirmFamily: onConfirmFamily,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.vanStudentsListFooter,
          textAlign: TextAlign.center,
          style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class VanStudentsSearchField extends StatefulWidget {
  const VanStudentsSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  State<VanStudentsSearchField> createState() => VanStudentsSearchFieldState();
}

class VanStudentsSearchFieldState extends State<VanStudentsSearchField> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: VanepColors.action,
      style: VanepTypography.fieldValue,
      decoration: vanepInputDecoration(
        hintText: l10n.vanStudentsSearchHint,
        prefixIcon: Icons.search,
      ),
    );
  }
}

class VanStudentsEmptyMessage extends StatelessWidget {
  const VanStudentsEmptyMessage({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: VanepTypography.body,
      ),
    );
  }
}
