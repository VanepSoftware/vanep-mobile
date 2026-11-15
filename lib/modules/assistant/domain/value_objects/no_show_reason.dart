enum NoShowReason {
  notAtStop,
  returnedHome,
  pickedUpByGuardian,
  sick,
  other;

  static NoShowReason? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'NOT_AT_STOP' => NoShowReason.notAtStop,
      'RETURNED_HOME' => NoShowReason.returnedHome,
      'PICKED_UP_BY_GUARDIAN' => NoShowReason.pickedUpByGuardian,
      'SICK' => NoShowReason.sick,
      'OTHER' => NoShowReason.other,
      _ => null,
    };
  }

  static String toApi(NoShowReason reason) {
    return switch (reason) {
      NoShowReason.notAtStop => 'NOT_AT_STOP',
      NoShowReason.returnedHome => 'RETURNED_HOME',
      NoShowReason.pickedUpByGuardian => 'PICKED_UP_BY_GUARDIAN',
      NoShowReason.sick => 'SICK',
      NoShowReason.other => 'OTHER',
    };
  }
}
