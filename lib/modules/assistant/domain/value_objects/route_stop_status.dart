enum RouteStopStatus {
  pending,
  arrived,
  done,
  skipped;

  bool get isFinished =>
      this == RouteStopStatus.done || this == RouteStopStatus.skipped;

  static RouteStopStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'PENDING' => RouteStopStatus.pending,
      'ARRIVED' => RouteStopStatus.arrived,
      'DONE' => RouteStopStatus.done,
      'SKIPPED' => RouteStopStatus.skipped,
      _ => null,
    };
  }

  static String toApi(RouteStopStatus status) {
    return switch (status) {
      RouteStopStatus.pending => 'PENDING',
      RouteStopStatus.arrived => 'ARRIVED',
      RouteStopStatus.done => 'DONE',
      RouteStopStatus.skipped => 'SKIPPED',
    };
  }
}
