import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_personal_data_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_pickup_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_days_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_editor_frame.dart';

Future<void> openDependentCreationWizard(BuildContext context) {
  return pushDependentWizard(context, DependentWizardCubit.create);
}

Future<void> openDependentCompletionWizard(
  BuildContext context, {
  required Dependent dependent,
  required Set<ContractReadinessField> gaps,
}) {
  return pushDependentWizard(
    context,
    () => DependentWizardCubit.complete(dependent: dependent, gaps: gaps),
  );
}

Future<void> pushDependentWizard(
  BuildContext context,
  DependentWizardCubit Function() createWizard,
) {
  final dependents = context.read<DependentsCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: dependents,
        child: DependentWizardPage(createWizard: createWizard),
      ),
    ),
  );
}

class DependentWizardPage extends StatelessWidget {
  const DependentWizardPage({required this.createWizard, super.key});

  final DependentWizardCubit Function() createWizard;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createWizard(),
      child: const DependentWizardView(),
    );
  }
}

class DependentWizardView extends StatelessWidget {
  const DependentWizardView({super.key});

  void finish(BuildContext context, DependentWizardState state) {
    final dependents = context.read<DependentsCubit>();
    final dependent = state.dependent;
    final navigator = Navigator.of(context);
    if (dependent == null) {
      navigator.pop();
      return;
    }
    unawaited(dependents.refreshReadiness());
    if (state.mode == DependentWizardMode.create) {
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => buildDependentDetail(dependents, dependent.token),
        ),
      );
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DependentWizardCubit, DependentWizardState>(
      listenWhen: (previous, current) =>
          !previous.isFinished && current.isFinished,
      listener: finish,
      buildWhen: (previous, current) => !current.isFinished,
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<DependentWizardCubit>().leave();
          },
          child: KeyedSubtree(
            key: ValueKey(state.index),
            child: DependentWizardStepView(state: state),
          ),
        );
      },
    );
  }
}

class DependentWizardStepView extends StatelessWidget {
  const DependentWizardStepView({required this.state, super.key});

  final DependentWizardState state;

  void keepDependent(BuildContext context, Dependent? saved) {
    if (saved != null) {
      final dependents = context.read<DependentsCubit>();
      if (dependents.state.dependentOf(saved.token) == null) {
        dependents.addDependent(saved);
      } else {
        dependents.replaceDependent(saved);
      }
    }
    context.read<DependentWizardCubit>().completeStep(dependent: saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wizard = context.read<DependentWizardCubit>();
    final title = dependentEditorTitle(l10n, state.currentStep);
    final caption = l10n.dependentWizardStepCaption(
      state.stepNumber,
      state.stepCount,
    );
    final label = state.isLastStep
        ? l10n.dependentWizardFinish
        : l10n.dependentWizardContinue;
    final skipLabel = state.canSkip ? l10n.dependentWizardSkip : null;
    final onSkip = state.canSkip ? wizard.skip : null;

    return switch (state.currentStep) {
      DependentWizardStep.personalData => BlocProvider(
        create: (_) =>
            getIt<DependentPersonalDataCubit>(param1: state.dependent),
        child: DependentEditorFrame(
          title: title,
          caption: caption,
          body: const DependentPersonalDataBody(),
          bottomBar:
              DependentEditorSaveBar<
                DependentPersonalDataCubit,
                DependentPersonalDataState
              >(
                label: label,
                skipLabel: skipLabel,
                onSkip: onSkip,
                onSaved: (saved) => keepDependent(context, saved.saved),
              ),
        ),
      ),
      DependentWizardStep.school => BlocProvider(
        create: (_) =>
            getIt<DependentSchoolCubit>(param1: state.savedDependent),
        child: DependentEditorFrame(
          title: title,
          caption: caption,
          body: const DependentSchoolBody(),
          bottomBar:
              DependentEditorSaveBar<
                DependentSchoolCubit,
                DependentSchoolState
              >(
                label: label,
                skipLabel: skipLabel,
                onSkip: onSkip,
                onSaved: (saved) => keepDependent(context, saved.saved),
              ),
        ),
      ),
      DependentWizardStep.schoolDays => BlocProvider(
        create: (_) =>
            getIt<DependentSchoolDaysCubit>(param1: state.savedDependent.token)
              ..load(),
        child: DependentEditorFrame(
          title: title,
          caption: caption,
          body: const DependentSchoolDaysBody(),
          bottomBar:
              DependentEditorSaveBar<
                DependentSchoolDaysCubit,
                DependentSchoolDaysState
              >(
                label: label,
                skipLabel: skipLabel,
                onSkip: onSkip,
                onSaved: (_) => keepDependent(context, null),
              ),
        ),
      ),
      DependentWizardStep.pickup => BlocProvider(
        create: (_) =>
            getIt<DependentPickupCubit>(param1: state.savedDependent),
        child: DependentEditorFrame(
          title: title,
          caption: caption,
          body: const DependentPickupBody(),
          bottomBar:
              DependentEditorSaveBar<
                DependentPickupCubit,
                DependentPickupState
              >(
                label: label,
                skipLabel: skipLabel,
                onSkip: onSkip,
                onSaved: (saved) => keepDependent(context, saved.saved),
              ),
        ),
      ),
    };
  }
}
