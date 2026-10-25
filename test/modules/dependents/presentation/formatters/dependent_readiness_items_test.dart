import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_readiness_items.dart';

void main() {
  test('without gaps every item is done', () {
    final items = dependentReadinessItems(const {});

    expect(items.every((item) => item.isDone), isTrue);
    expect(countDoneReadinessItems(items), 4);
  });

  test('a missing field is not done', () {
    final items = dependentReadinessItems(const {
      ContractReadinessField.school,
      ContractReadinessField.schoolDays,
    });

    expect([for (final item in items) item.isDone], [true, true, false, false]);
    expect(countDoneReadinessItems(items), 2);
  });

  test('the checklist follows birth date, pickup, school and school days', () {
    final items = dependentReadinessItems(const {});

    expect(
      [for (final item in items) item.step],
      const [
        DependentWizardStep.personalData,
        DependentWizardStep.pickup,
        DependentWizardStep.school,
        DependentWizardStep.schoolDays,
      ],
    );
  });

  test('the missing steps come in the order of the creation', () {
    expect(
      dependentWizardStepsFor(const {
        ContractReadinessField.address,
        ContractReadinessField.school,
        ContractReadinessField.birthDate,
      }),
      const [
        DependentWizardStep.personalData,
        DependentWizardStep.school,
        DependentWizardStep.pickup,
      ],
    );
  });

  test('client fields never become a step', () {
    expect(
      dependentWizardStepsFor(const {
        ContractReadinessField.phone,
        ContractReadinessField.document,
      }),
      isEmpty,
    );
  });
}
