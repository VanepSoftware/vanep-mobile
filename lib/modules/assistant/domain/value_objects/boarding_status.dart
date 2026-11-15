enum BoardingStatus {
  pending,
  boarded,
  droppedOff,
  noShow;

  static BoardingStatus fromApi(Object? raw) {
    if (raw is! String) return BoardingStatus.pending;
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'BOARDED' => BoardingStatus.boarded,
      'DROPPED_OFF' || 'DROPPEDOFF' => BoardingStatus.droppedOff,
      'NO_SHOW' || 'NOSHOW' => BoardingStatus.noShow,
      _ => BoardingStatus.pending,
    };
  }

  static String toApi(BoardingStatus status) {
    return switch (status) {
      BoardingStatus.pending => 'PENDING',
      BoardingStatus.boarded => 'BOARDED',
      BoardingStatus.droppedOff => 'DROPPED_OFF',
      BoardingStatus.noShow => 'NO_SHOW',
    };
  }
}
