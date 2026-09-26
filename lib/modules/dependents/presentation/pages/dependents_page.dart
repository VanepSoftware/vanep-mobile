import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dependent.dart';
import '../cubit/dependents_cubit.dart';
import '../cubit/dependents_state.dart';
import '../formatters/dependent_labels.dart';
import '../widgets/dependent_card.dart';
import 'dependent_form_page.dart';

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
        final isListing =
            !(state.isLoading && state.dependents.isEmpty) &&
            !state.hasLoadFailed;

        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
          body: DependentsBody(state: state),
          bottomNavigationBar: isListing
              ? VanepBottomBar(
                  child: VanepPrimaryButton(
                    label: l10n.dependentsAdd,
                    onPressed: () => openDependentForm(context),
                  ),
                )
              : null,
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
    if (state.isLoading && state.dependents.isEmpty) {
      return const DependentsSkeleton(
        child: VanepSkeletonList(buildPlaceholder: buildDependentCardSkeleton),
      );
    }
    if (state.hasLoadFailed) {
      return DependentsSkeleton(
        child: DependentsLoadFailure(
          onRetry: context.read<DependentsCubit>().loadDependents,
        ),
      );
    }
    return DependentsList(state: state);
  }
}

class DependentsSkeleton extends StatelessWidget {
  const DependentsSkeleton({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VanepPageHeader(
            title: l10n.profileDependents,
            subtitle: l10n.dependentsSubtitle,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DependentsList extends StatelessWidget {
  const DependentsList({required this.state, super.key});

  final DependentsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentsCubit>();

    return RefreshIndicator(
      color: VanepColors.action,
      onRefresh: cubit.loadDependents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          VanepPageHeader(
            title: l10n.profileDependents,
            subtitle: l10n.dependentsSubtitle,
          ),
          if (state.isEmpty)
            Text(l10n.dependentsEmpty, style: VanepTypography.cardSubtitle),
          for (final dependent in state.dependents)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DependentCard(
                dependent: dependent,
                canChooseDefault: state.canChooseDefault,
                onChooseDefault: () => cubit.chooseDefault(dependent.token),
                onEdit: () => openDependentForm(context, dependent: dependent),
              ),
            ),
        ],
      ),
    );
  }
}

class DependentsLoadFailure extends StatelessWidget {
  const DependentsLoadFailure({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.dependentsLoadError,
            textAlign: TextAlign.center,
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          VanepPrimaryButton(label: l10n.dependentsRetry, onPressed: onRetry),
        ],
      ),
    );
  }
}

Future<void> openDependentForm(
  BuildContext context, {
  Dependent? dependent,
}) async {
  final cubit = context.read<DependentsCubit>();
  final l10n = AppLocalizations.of(context)!;
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => DependentFormPage(dependent: dependent),
    ),
  );
  if (!context.mounted) return;
  if (saved ?? false) {
    VanepFeedback.showInfo(context, l10n.dependentFormSaved);
    await cubit.loadDependents();
  }
}
