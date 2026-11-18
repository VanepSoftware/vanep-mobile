enum RegistrationStatus {
  incomplete,
  underReview,
  rejected,
  approved;

  static RegistrationStatus fromApi(Object? raw) {
    if (raw is! String) return RegistrationStatus.incomplete;
    return switch (raw.trim().toUpperCase()) {
      'PENDING' || 'INCOMPLETE' => RegistrationStatus.incomplete,
      'UNDER_REVIEW' => RegistrationStatus.underReview,
      'REJECTED' => RegistrationStatus.rejected,
      'APPROVED' => RegistrationStatus.approved,
      _ => RegistrationStatus.incomplete,
    };
  }
}
