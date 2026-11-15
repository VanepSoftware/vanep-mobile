import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_wizard_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependents_list_card.dart';

class DependentsPage extends StatelessWidget {
  const DependentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DependentsCubit, DependentsState>(
      listenWhen: (previous, current) =>
          current.failure != null && previous.failure != current.failure,
      listener: (context, state) {
        if (state.hasLoadFailed) return;
        VanepFeedback.showError(
          context,
          dependentFailureLabel(l10n, state.failure!),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: VanepColors.surface,
          body: SafeArea(bottom: false, child: DependentsBody(state: state)),
        );
      },
    );
  }
}

class DependentsBody extends StatelessWidget {
  const DependentsBody({required this.state, super.key});

  final DependentsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentsCubit>();
    void add() => openDependentCreationWizard(context);
    final header = DependentsHeader(onAdd: add);
    const padding = EdgeInsets.fromLTRB(20, 24, 20, 32);

    if (state.isLoading && state.dependents.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          header,
          VanepSkeleton(
            child: DependentsListCard(
              rows: [
                for (var row = 0; row < 3; row++)
                  const DependentListRowSkeleton(),
              ],
            ),
          ),
        ],
      );
    }
    if (state.hasLoadFailed) {
      return ListView(
        padding: padding,
        children: [
          header,
          VanepErrorView(
            message: l10n.dependentsLoadError,
            retryLabel: l10n.dependentsRetry,
            onRetry: cubit.loadDependents,
          ),
        ],
      );
    }
    return RefreshIndicator(
      color: VanepColors.action,
      onRefresh: cubit.loadDependents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          header,
          if (state.isEmpty)
            DependentsEmptyState(onAdd: add)
          else ...[
            DependentsListCard(
              rows: [
                for (final dependent in state.dependents)
                  DependentListRow(
                    dependent: dependent,
                    isIncomplete: state.isIncomplete(dependent.token),
                    onTap: () => openDependentDetail(context, dependent.token),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            VanepSecondaryButton(
              label: l10n.dependentsAdd,
              icon: Icons.person_add_alt_1_outlined,
              onPressed: add,
            ),
          ],
        ],
      ),
    );
  }
}

class DependentsHeader extends StatelessWidget {
  const DependentsHeader({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dependentsTitle, style: VanepTypography.pageTitle),
                const SizedBox(height: 6),
                Text(
                  l10n.dependentsSubtitle,
                  style: VanepTypography.cardSubtitle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.dependentsAddTooltip,
            onPressed: onAdd,
            style: IconButton.styleFrom(
              backgroundColor: VanepColors.card,
              side: const BorderSide(color: VanepColors.inputBorder),
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.add, color: VanepColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class DependentsEmptyState extends StatelessWidget {
  const DependentsEmptyState({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Icon(
          Icons.family_restroom_outlined,
          size: 48,
          color: VanepColors.textMuted,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.dependentsEmpty,
          textAlign: TextAlign.center,
          style: VanepTypography.cardSubtitle.copyWith(
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        VanepPrimaryButton(label: l10n.dependentsAdd, onPressed: onAdd),
      ],
    );
  }
}
