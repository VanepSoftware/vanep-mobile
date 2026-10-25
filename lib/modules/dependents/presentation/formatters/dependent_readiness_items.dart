import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';

const Map<ContractReadinessField, DependentWizardStep>
dependentReadinessChecklist = {
  ContractReadinessField.birthDate: DependentWizardStep.personalData,
  ContractReadinessField.address: DependentWizardStep.pickup,
  ContractReadinessField.school: DependentWizardStep.school,
  ContractReadinessField.schoolDays: DependentWizardStep.schoolDays,
};

class DependentReadinessItem extends Equatable {
  const DependentReadinessItem({required this.step, required this.isDone});

  final DependentWizardStep step;

  final bool isDone;

  @override
  List<Object?> get props => [step, isDone];
}

List<DependentReadinessItem> dependentReadinessItems(
  Set<ContractReadinessField> gaps,
) {
  return [
    for (final MapEntry(key: field, value: step)
        in dependentReadinessChecklist.entries)
      DependentReadinessItem(step: step, isDone: !gaps.contains(field)),
  ];
}

int countDoneReadinessItems(List<DependentReadinessItem> items) {
  return items.where((item) => item.isDone).length;
}

List<DependentWizardStep> dependentWizardStepsFor(
  Set<ContractReadinessField> gaps,
) {
  final missing = {
    for (final item in dependentReadinessItems(gaps))
      if (!item.isDone) item.step,
  };
  return [
    for (final step in DependentWizardStep.values)
      if (missing.contains(step)) step,
  ];
}
