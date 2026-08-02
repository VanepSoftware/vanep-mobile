enum DriverApprovalStatus {
  pending,
  approved,
  rejected;

  static DriverApprovalStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'PENDING' => DriverApprovalStatus.pending,
      'APPROVED' => DriverApprovalStatus.approved,
      'REJECTED' => DriverApprovalStatus.rejected,
      _ => null,
    };
  }

  static String? toApi(DriverApprovalStatus? status) {
    return switch (status) {
      DriverApprovalStatus.pending => 'PENDING',
      DriverApprovalStatus.approved => 'APPROVED',
      DriverApprovalStatus.rejected => 'REJECTED',
      null => null,
    };
  }
}
