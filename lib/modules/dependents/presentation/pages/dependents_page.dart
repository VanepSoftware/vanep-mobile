import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_screen_background.dart';
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

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.profileDependents),
        ),
        body: BlocConsumer<DependentsCubit, DependentsState>(
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
            if (state.isLoading && state.dependents.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.hasLoadFailed) {
              return DependentsLoadFailure(
                onRetry: context.read<DependentsCubit>().loadDependents,
              );
            }
            return DependentsList(state: state);
          },
        ),
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
      onRefresh: cubit.loadDependents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.dependentsSubtitle, style: VanepTypography.cardSubtitle),
          const SizedBox(height: 16),
          if (state.isEmpty)
            Text(l10n.dependentsEmpty, style: VanepTypography.cardSubtitle),
          for (final dependent in state.dependents)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DependentCard(
                dependent: dependent,
                canChooseDefault: state.canChooseDefault,
                onChooseDefault: () => cubit.chooseDefault(dependent.token),
                onEdit: () => openDependentForm(context, dependent: dependent),
              ),
            ),
          const SizedBox(height: 12),
          VanepPrimaryButton(
            label: l10n.dependentsAdd,
            onPressed: () => openDependentForm(context),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dependentsLoadError,
              textAlign: TextAlign.center,
              style: VanepTypography.cardSubtitle,
            ),
            const SizedBox(height: 16),
            VanepPrimaryButton(
              label: l10n.dependentsRetry,
              onPressed: onRetry,
            ),
          ],
        ),
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
