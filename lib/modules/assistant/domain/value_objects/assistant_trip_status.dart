// TODO(VAN-67): `TripStatus` is owned by the trip module of
// driver-route-operation (#150), which is not on main yet. When it merges,
// replace this enum with that one; the driver home must not get a third copy.
enum AssistantTripStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  static AssistantTripStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'SCHEDULED' => AssistantTripStatus.scheduled,
      'IN_PROGRESS' => AssistantTripStatus.inProgress,
      'COMPLETED' => AssistantTripStatus.completed,
      'CANCELLED' => AssistantTripStatus.cancelled,
      _ => null,
    };
  }

  static String toApi(AssistantTripStatus status) {
    return switch (status) {
      AssistantTripStatus.scheduled => 'SCHEDULED',
      AssistantTripStatus.inProgress => 'IN_PROGRESS',
      AssistantTripStatus.completed => 'COMPLETED',
      AssistantTripStatus.cancelled => 'CANCELLED',
    };
  }
}
