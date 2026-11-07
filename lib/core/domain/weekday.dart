enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static Weekday? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toLowerCase();
    for (final day in Weekday.values) {
      if (day.name == normalized) return day;
    }
    return null;
  }

  static String? toApi(Weekday? day) => day?.name.toUpperCase();
}
