import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';

enum DependentWizardMode { create, complete }

class DependentWizardState extends Equatable {
  const DependentWizardState({
    required this.mode,
    required this.steps,
    this.index = 0,
    this.dependent,
    this.isFinished = false,
  });

  final DependentWizardMode mode;

  final List<DependentWizardStep> steps;

  final int index;

  final Dependent? dependent;

  final bool isFinished;

  DependentWizardStep get currentStep => steps[index];

  // Creating cannot skip the personal data step and completing starts with a
  // dependent, so every step after personal data has the dependent it edits.
  Dependent get savedDependent => dependent!;

  int get stepNumber => index + 1;

  int get stepCount => steps.length;

  bool get isLastStep => index == steps.length - 1;

  bool get canSkip =>
      mode == DependentWizardMode.complete ||
      currentStep != DependentWizardStep.personalData;

  DependentWizardState copyWith({
    int? index,
    Dependent? dependent,
    bool? isFinished,
  }) {
    return DependentWizardState(
      mode: mode,
      steps: steps,
      index: index ?? this.index,
      dependent: dependent ?? this.dependent,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  @override
  List<Object?> get props => [mode, steps, index, dependent, isFinished];
}
