int calendarDaysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}

const weekdaysMondayToFriday = [
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];

bool isMondayToFriday(List<int> weekdays) {
  final sorted = [...weekdays]..sort();
  return sorted.length == weekdaysMondayToFriday.length &&
      sorted.indexed.every(
        (entry) => entry.$2 == weekdaysMondayToFriday[entry.$1],
      );
}
