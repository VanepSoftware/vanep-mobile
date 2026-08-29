enum OnboardingStep {
  personalAddress,
  serviceArea;

  static OnboardingStep? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'PERSONAL_ADDRESS' => OnboardingStep.personalAddress,
      'SERVICE_AREA' => OnboardingStep.serviceArea,
      _ => null,
    };
  }

  static List<OnboardingStep> listFromApi(Object? raw) {
    if (raw is! Map) return const [];
    final steps = raw['pendingSteps'];
    if (steps is! List) return const [];
    return steps.map(OnboardingStep.fromApi).whereType<OnboardingStep>().toList();
  }
}
