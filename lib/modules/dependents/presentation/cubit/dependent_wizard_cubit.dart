import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_readiness_items.dart';

class DependentWizardCubit extends Cubit<DependentWizardState> {
  DependentWizardCubit.create()
    : super(
        const DependentWizardState(
          mode: DependentWizardMode.create,
          steps: DependentWizardStep.values,
        ),
      );

  DependentWizardCubit.complete({
    required Dependent dependent,
    required Set<ContractReadinessField> gaps,
  }) : super(
         DependentWizardState(
           mode: DependentWizardMode.complete,
           steps: dependentWizardStepsFor(gaps),
           dependent: dependent,
         ),
       );

  void completeStep({Dependent? dependent}) {
    if (state.isFinished) return;
    emit(state.copyWith(dependent: dependent));
    advance();
  }

  void skip() {
    if (state.isFinished || !state.canSkip) return;
    advance();
  }

  void advance() {
    if (state.isLastStep) {
      emit(state.copyWith(isFinished: true));
      return;
    }
    emit(state.copyWith(index: state.index + 1));
  }

  void leave() => emit(state.copyWith(isFinished: true));
}
