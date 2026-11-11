enum TripStatus {
  notStarted,
  inProgress,
  completed;

  static TripStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'SCHEDULED' || 'NOT_STARTED' => TripStatus.notStarted,
      'IN_PROGRESS' => TripStatus.inProgress,
      'COMPLETED' => TripStatus.completed,
      _ => null,
    };
  }
}
