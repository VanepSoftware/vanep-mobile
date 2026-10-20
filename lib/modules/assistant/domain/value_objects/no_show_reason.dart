enum NoShowReason {
  notifiedByGuardian,
  notAtLocation,
  other;

  static NoShowReason? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'NOTIFIED_BY_GUARDIAN' => NoShowReason.notifiedByGuardian,
      'NOT_AT_LOCATION' => NoShowReason.notAtLocation,
      'OTHER' => NoShowReason.other,
      _ => null,
    };
  }

  static String toApi(NoShowReason reason) {
    return switch (reason) {
      NoShowReason.notifiedByGuardian => 'NOTIFIED_BY_GUARDIAN',
      NoShowReason.notAtLocation => 'NOT_AT_LOCATION',
      NoShowReason.other => 'OTHER',
    };
  }
}
