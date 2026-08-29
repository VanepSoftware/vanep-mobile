import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/onboarding_step.dart';

void main() {
  test('reads the pending steps the API sends', () {
    final steps = OnboardingStep.listFromApi(const {
      'pendingSteps': ['PERSONAL_ADDRESS', 'SERVICE_AREA'],
    });

    expect(steps, [
      OnboardingStep.personalAddress,
      OnboardingStep.serviceArea,
    ]);
  });

  test('an absent onboarding object means nothing is pending', () {
    expect(OnboardingStep.listFromApi(null), isEmpty);
    expect(OnboardingStep.listFromApi(const <String, Object?>{}), isEmpty);
  });

  test('an empty list means the registration is complete', () {
    expect(
      OnboardingStep.listFromApi(const {'pendingSteps': <Object?>[]}),
      isEmpty,
    );
  });

  /// Um passo novo no backend não pode derrubar o app: ele é ignorado até a
  /// versão que o entende chegar.
  test('an unknown step is ignored instead of breaking', () {
    final steps = OnboardingStep.listFromApi(const {
      'pendingSteps': ['SERVICE_AREA', 'SOMETHING_NEW'],
    });

    expect(steps, [OnboardingStep.serviceArea]);
  });
}
