enum DocumentField {
  documentNumber,
  expiresAt,
  cnhRegistrationNumber,
  cnhCategory,
  cnhIssueDate,
  cnhIssuingState,
}

enum DocumentFieldError {
  required,
  tooLong,
  invalidFormat,
  alreadyExpired,
  tooFar,
  beforeIssue,
  inFuture,
}
