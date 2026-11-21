enum ChecklistStatus {
  pending,
  done,
  skipped,
  absent;

  static ChecklistStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'PENDING' => ChecklistStatus.pending,
      'DONE' => ChecklistStatus.done,
      'SKIPPED' => ChecklistStatus.skipped,
      'ABSENT' => ChecklistStatus.absent,
      _ => null,
    };
  }

  static String toApi(ChecklistStatus status) {
    return switch (status) {
      ChecklistStatus.pending => 'PENDING',
      ChecklistStatus.done => 'DONE',
      ChecklistStatus.skipped => 'SKIPPED',
      ChecklistStatus.absent => 'ABSENT',
    };
  }
}
