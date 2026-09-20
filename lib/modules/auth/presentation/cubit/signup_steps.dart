import '../../domain/value_objects/account_field.dart';

enum SignupStep {
  access({
    AccountField.name,
    AccountField.email,
    AccountField.password,
    AccountField.passwordConfirmation,
  }),
  personal({
    AccountField.document,
    AccountField.phone,
    AccountField.birthDate,
    AccountField.gender,
  }),
  professional({
    AccountField.basePrice,
    AccountField.experienceYears,
    AccountField.cnpj,
  }),
  confirmation({AccountField.acceptTerms});

  const SignupStep(this.fields);

  final Set<AccountField> fields;
}

List<SignupStep> signupStepsFor({
  required bool isDriver,
  required bool isGoogleSignup,
}) {
  return [
    if (!isGoogleSignup) SignupStep.access,
    SignupStep.personal,
    if (isDriver) SignupStep.professional,
    SignupStep.confirmation,
  ];
}

Map<AccountField, AccountFieldIssue> issuesOfStep(
  Map<AccountField, AccountFieldIssue> issues,
  SignupStep step,
) {
  return {
    for (final entry in issues.entries)
      if (step.fields.contains(entry.key)) entry.key: entry.value,
  };
}

Map<AccountField, AccountFieldIssue> issuesOutsideStep(
  Map<AccountField, AccountFieldIssue> issues,
  SignupStep step,
) {
  return {
    for (final entry in issues.entries)
      if (!step.fields.contains(entry.key)) entry.key: entry.value,
  };
}

int? firstStepIndexWithIssues(
  List<SignupStep> steps,
  Map<AccountField, AccountFieldIssue> issues,
) {
  for (var stepIndex = 0; stepIndex < steps.length; stepIndex++) {
    if (issuesOfStep(issues, steps[stepIndex]).isNotEmpty) return stepIndex;
  }
  return null;
}
