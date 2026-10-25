import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_menu_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_personal_data_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_pickup_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_days_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_wizard_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_header_card.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_readiness_card.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_school_week_bar.dart';

Future<void> openDependentDetail(BuildContext context, String token) {
  final dependents = context.read<DependentsCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => buildDependentDetail(dependents, token),
    ),
  );
}

Widget buildDependentDetail(DependentsCubit dependents, String token) {
  return BlocProvider.value(
    value: dependents,
    child: DependentDetailPage(token: token),
  );
}

class DependentDetailPage extends StatelessWidget {
  const DependentDetailPage({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DependentDetailCubit>(param1: token)..loadSchoolWeek(),
      child: DependentDetailView(token: token),
    );
  }
}

class DependentDetailView extends StatelessWidget {
  const DependentDetailView({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DependentsCubit, DependentsState>(
      buildWhen: (_, current) => current.dependentOf(token) != null,
      builder: (context, dependentsState) {
        final dependent = dependentsState.dependentOf(token);
        if (dependent == null) {
          return const Scaffold(
            backgroundColor: VanepColors.surface,
            appBar: VanepAppBar(),
          );
        }
        final gaps = dependentsState.gapsOf(token);
        final canSetDefault =
            dependentsState.canChooseDefault && !dependent.isDefault;

        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(
            title: dependentFirstName(dependent.name),
            caption: l10n.dependentDetailCaption,
            actions: [
              if (canSetDefault)
                DependentDetailMenu(
                  onSetDefault: () => setAsDefault(context, dependent),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: withSpacing([
              DependentHeaderCard(dependent: dependent),
              if (gaps != null && gaps.isNotEmpty)
                DependentReadinessCard(
                  gaps: gaps,
                  onComplete: () => completeProfile(context, dependent),
                ),
              VanepSection(
                title: l10n.dependentDetailGroupSchool,
                child: DependentSchoolRoutineCard(dependent: dependent),
              ),
              VanepSection(
                title: l10n.dependentDetailGroupVan,
                child: VanepMenuCard(
                  items: [
                    VanepMenuItem(
                      label: l10n.dependentRowVan,
                      icon: Icons.airport_shuttle_outlined,
                    ),
                    VanepMenuItem(
                      label: l10n.dependentRowContract,
                      icon: Icons.description_outlined,
                    ),
                  ],
                ),
              ),
              VanepSection(
                title: l10n.dependentDetailGroupRegistration,
                child: VanepMenuCard(
                  items: [
                    VanepMenuItem(
                      label: l10n.dependentRowPersonalData,
                      icon: Icons.badge_outlined,
                      warningSubtitle: dependent.birthDate == null
                          ? l10n.dependentNotInformed
                          : null,
                      onTap: () => editDependent(
                        context,
                        () => openDependentPersonalData(
                          context,
                          dependent: dependent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => confirmRemoval(context, dependent),
                  style: TextButton.styleFrom(
                    foregroundColor: VanepColors.danger,
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(l10n.dependentRemove),
                ),
              ),
            ], 20),
          ),
        );
      },
    );
  }
}

class DependentSchoolRoutineCard extends StatelessWidget {
  const DependentSchoolRoutineCard({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final school = dependent.school;
    final pickup = dependentPickupSummary(dependent.address);

    return BlocBuilder<DependentDetailCubit, DependentDetailState>(
      builder: (context, detailState) {
        return VanepMenuCard(
          items: [
            VanepMenuItem(
              label: l10n.dependentRowSchool,
              icon: Icons.school_outlined,
              warningSubtitle: school == null
                  ? l10n.dependentNotInformed
                  : null,
              content: school == null
                  ? null
                  : Text(
                      school.name,
                      style: VanepTypography.cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => editDependent(
                context,
                () => openDependentSchool(context, dependent: dependent),
              ),
            ),
            schoolDaysItem(context, detailState),
            VanepMenuItem(
              label: l10n.dependentRowPickup,
              icon: Icons.home_outlined,
              warningSubtitle: dependent.address == null
                  ? l10n.dependentNotInformed
                  : null,
              content: pickup == null
                  ? null
                  : Text(
                      pickup,
                      style: VanepTypography.cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => editDependent(
                context,
                () => openDependentPickup(context, dependent: dependent),
              ),
            ),
          ],
        );
      },
    );
  }

  VanepMenuItem schoolDaysItem(
    BuildContext context,
    DependentDetailState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final week = state.week;
    final hasDays = week != null && !week.isEmpty;

    return VanepMenuItem(
      label: l10n.dependentRowSchoolDays,
      icon: Icons.calendar_month_outlined,
      warningSubtitle: week != null && week.isEmpty
          ? l10n.dependentNotInformed
          : null,
      semanticsLabel: hasDays
          ? l10n.dependentSchoolDaysSemantics(
              l10n.dependentSchoolDayCount(week.dayCount),
            )
          : null,
      content: switch (state.status) {
        DependentDetailStatus.loading => const DependentSchoolWeekBarSkeleton(),
        DependentDetailStatus.loadFailed => Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: context.read<DependentDetailCubit>().loadSchoolWeek,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 32),
            ),
            child: Text(l10n.dependentsRetry),
          ),
        ),
        DependentDetailStatus.loaded =>
          hasDays ? DependentSchoolWeekBar(week: week) : null,
      },
      onTap: () => editSchoolDays(context, dependent),
    );
  }
}

class DependentDetailMenu extends StatelessWidget {
  const DependentDetailMenu({required this.onSetDefault, super.key});

  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<VoidCallback>(
      tooltip: l10n.dependentDetailMoreOptions,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => action(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: onSetDefault,
          child: Text(l10n.dependentsSetDefault),
        ),
      ],
    );
  }
}

Future<void> editDependent(
  BuildContext context,
  Future<Dependent?> Function() openEditor,
) async {
  final dependents = context.read<DependentsCubit>();
  final saved = await openEditor();
  if (saved == null) return;
  dependents.replaceDependent(saved);
  await dependents.refreshReadiness();
}

Future<void> editSchoolDays(BuildContext context, Dependent dependent) async {
  final dependents = context.read<DependentsCubit>();
  final detail = context.read<DependentDetailCubit>();
  final week = await openDependentSchoolDays(context, dependent: dependent);
  if (week == null) return;
  detail.applySavedWeek(week);
  await dependents.refreshReadiness();
}

Future<void> completeProfile(BuildContext context, Dependent dependent) async {
  final detail = context.read<DependentDetailCubit>();
  final gaps = context.read<DependentsCubit>().state.gapsOf(dependent.token);
  if (gaps == null) return;
  await openDependentCompletionWizard(
    context,
    dependent: dependent,
    gaps: gaps,
  );
  await detail.loadSchoolWeek();
}

Future<void> setAsDefault(BuildContext context, Dependent dependent) async {
  final l10n = AppLocalizations.of(context)!;
  final dependents = context.read<DependentsCubit>();
  await dependents.chooseDefault(dependent.token);
  if (!context.mounted) return;
  if (dependents.state.defaultToken == dependent.token) {
    VanepFeedback.showInfo(context, l10n.dependentsDefaultUpdated);
  }
}

Future<void> confirmRemoval(BuildContext context, Dependent dependent) async {
  final l10n = AppLocalizations.of(context)!;
  final firstName = dependentFirstName(dependent.name);
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.dependentRemoveTitle(firstName),
    message: l10n.dependentRemoveMessage(firstName),
    confirmLabel: l10n.dependentRemoveConfirm,
    cancelLabel: l10n.dependentRemoveCancel,
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final failure = await context.read<DependentsCubit>().removeDependent(
    dependent.token,
  );
  if (!context.mounted) return;
  if (failure != null) {
    VanepFeedback.showError(context, dependentFailureLabel(l10n, failure));
    return;
  }
  VanepFeedback.showInfo(context, l10n.dependentRemoved(firstName));
  Navigator.of(context).pop();
}
