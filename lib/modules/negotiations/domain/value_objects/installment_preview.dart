int? previewInstallmentAmount(int totalCents, int installments) {
  if (installments <= 0) return null;
  return totalCents ~/ installments;
}
