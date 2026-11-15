import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';

import '../dependents_fixtures.dart';

void main() {
  group('creating', () {
    test('has the four steps and the first one cannot be skipped', () {
      final cubit = DependentWizardCubit.create();
      addTearDown(cubit.close);

      expect(cubit.state.steps, DependentWizardStep.values);
      expect(cubit.state.currentStep, DependentWizardStep.personalData);
      expect(cubit.state.stepNumber, 1);
      expect(cubit.state.stepCount, 4);
      expect(cubit.state.canSkip, isFalse);

      cubit.skip();

      expect(cubit.state.currentStep, DependentWizardStep.personalData);
    });

    test('the first step keeps the created dependent and moves on', () {
      final cubit = DependentWizardCubit.create();
      addTearDown(cubit.close);

      cubit.completeStep(dependent: testHelenaDependent);

      expect(cubit.state.dependent, testHelenaDependent);
      expect(cubit.state.currentStep, DependentWizardStep.school);
      expect(cubit.state.canSkip, isTrue);
    });

    test('skipping moves on without touching the dependent', () {
      final cubit = DependentWizardCubit.create()
        ..completeStep(dependent: testHelenaDependent);
      addTearDown(cubit.close);

      cubit.skip();

      expect(cubit.state.currentStep, DependentWizardStep.schoolDays);
      expect(cubit.state.dependent, testHelenaDependent);
    });

    test('a step that did not save stays on the screen', () {
      final cubit = DependentWizardCubit.create()
        ..completeStep(dependent: testHelenaDependent);
      addTearDown(cubit.close);

      expect(cubit.state.currentStep, DependentWizardStep.school);
      expect(cubit.state.isFinished, isFalse);
    });

    test('the last step finishes the wizard', () {
      final cubit = DependentWizardCubit.create()
        ..completeStep(dependent: testHelenaDependent)
        ..skip()
        ..completeStep()
        ..completeStep(dependent: testMiguelDependent);
      addTearDown(cubit.close);

      expect(cubit.state.isFinished, isTrue);
      expect(cubit.state.dependent, testMiguelDependent);
    });

    test('the last step is the one before finishing', () {
      final cubit = DependentWizardCubit.create()
        ..completeStep(dependent: testHelenaDependent)
        ..skip()
        ..skip();
      addTearDown(cubit.close);

      expect(cubit.state.currentStep, DependentWizardStep.pickup);
      expect(cubit.state.isLastStep, isTrue);
    });

    test('leaving from the first step ends without a dependent', () {
      final cubit = DependentWizardCubit.create();
      addTearDown(cubit.close);

      cubit.leave();

      expect(cubit.state.isFinished, isTrue);
      expect(cubit.state.dependent, isNull);
    });

    test('leaving after the creation ends with the created dependent', () {
      final cubit = DependentWizardCubit.create()
        ..completeStep(dependent: testHelenaDependent);
      addTearDown(cubit.close);

      cubit.leave();

      expect(cubit.state.isFinished, isTrue);
      expect(cubit.state.dependent, testHelenaDependent);
    });
  });

  group('completing', () {
    test('only the missing steps, in the order of the creation', () {
      final cubit = DependentWizardCubit.complete(
        dependent: testHelenaDependent,
        gaps: const {
          ContractReadinessField.schoolDays,
          ContractReadinessField.school,
        },
      );
      addTearDown(cubit.close);

      expect(cubit.state.mode, DependentWizardMode.complete);
      expect(cubit.state.steps, const [
        DependentWizardStep.school,
        DependentWizardStep.schoolDays,
      ]);
      expect(cubit.state.stepCount, 2);
      expect(cubit.state.dependent, testHelenaDependent);
    });

    test('every step can be skipped, the personal data one included', () {
      final cubit = DependentWizardCubit.complete(
        dependent: testHelenaDependent,
        gaps: const {ContractReadinessField.birthDate},
      );
      addTearDown(cubit.close);

      expect(cubit.state.currentStep, DependentWizardStep.personalData);
      expect(cubit.state.canSkip, isTrue);

      cubit.skip();

      expect(cubit.state.isFinished, isTrue);
    });
  });
}
