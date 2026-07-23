enum Gender {
  male,
  female,
  other;

  static Gender? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'MALE' => Gender.male,
      'FEMALE' => Gender.female,
      'OTHER' => Gender.other,
      _ => null,
    };
  }

  static String? toApi(Gender? gender) {
    return switch (gender) {
      Gender.male => 'MALE',
      Gender.female => 'FEMALE',
      Gender.other => 'OTHER',
      null => null,
    };
  }
}
