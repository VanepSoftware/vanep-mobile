enum SchoolShift {
  morning,
  afternoon,
  night,
  fullTime;

  static SchoolShift? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'MORNING' => SchoolShift.morning,
      'AFTERNOON' => SchoolShift.afternoon,
      'NIGHT' => SchoolShift.night,
      'FULLTIME' => SchoolShift.fullTime,
      _ => null,
    };
  }

  static String? toApi(SchoolShift? shift) {
    return switch (shift) {
      SchoolShift.morning => 'MORNING',
      SchoolShift.afternoon => 'AFTERNOON',
      SchoolShift.night => 'NIGHT',
      SchoolShift.fullTime => 'FULLTIME',
      null => null,
    };
  }
}
