enum CepFailure {
  invalidFormat,
  notFound,
  cityNotInCatalog,
  rateLimited,
  unavailable,
  network,
  unexpected,
}

extension CepFailureBlockingSave on CepFailure {
  bool get blocksSave =>
      this == CepFailure.notFound || this == CepFailure.rateLimited;
}
