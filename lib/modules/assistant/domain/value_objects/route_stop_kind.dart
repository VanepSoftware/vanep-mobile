enum TripLeg { outbound, inbound }

enum RouteStopKind {
  pickupHome,
  dropOffSchool,
  pickupSchool,
  dropOffHome;

  TripLeg get leg => switch (this) {
    RouteStopKind.pickupHome || RouteStopKind.dropOffSchool => TripLeg.outbound,
    RouteStopKind.pickupSchool || RouteStopKind.dropOffHome => TripLeg.inbound,
  };

  bool get isBoarding =>
      this == RouteStopKind.pickupHome || this == RouteStopKind.pickupSchool;

  bool get isAtSchool =>
      this == RouteStopKind.dropOffSchool || this == RouteStopKind.pickupSchool;

  static RouteStopKind? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'PICKUP_HOME' => RouteStopKind.pickupHome,
      'DROPOFF_SCHOOL' => RouteStopKind.dropOffSchool,
      'PICKUP_SCHOOL' => RouteStopKind.pickupSchool,
      'DROPOFF_HOME' => RouteStopKind.dropOffHome,
      _ => null,
    };
  }

  static String toApi(RouteStopKind kind) {
    return switch (kind) {
      RouteStopKind.pickupHome => 'PICKUP_HOME',
      RouteStopKind.dropOffSchool => 'DROPOFF_SCHOOL',
      RouteStopKind.pickupSchool => 'PICKUP_SCHOOL',
      RouteStopKind.dropOffHome => 'DROPOFF_HOME',
    };
  }
}
