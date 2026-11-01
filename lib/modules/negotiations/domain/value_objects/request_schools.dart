import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

class SchoolGroup<T extends RequestItem> {
  const SchoolGroup({
    required this.schoolName,
    required this.items,
    required this.shifts,
  });

  final String? schoolName;

  final List<T> items;

  final Set<SchoolShift> shifts;

  SchoolShift? get shift => shifts.length == 1 ? shifts.single : null;

  bool get hasVaryingShift => shifts.length > 1;
}

List<SchoolGroup<T>> groupItemsBySchool<T extends RequestItem>(List<T> items) {
  final itemsBySchool = <String?, List<T>>{};
  for (final item in items) {
    itemsBySchool.putIfAbsent(item.schoolName, () => []).add(item);
  }
  return [
    for (final MapEntry(key: schoolName, value: schoolItems)
        in itemsBySchool.entries)
      SchoolGroup(
        schoolName: schoolName,
        items: schoolItems,
        shifts: {
          for (final item in schoolItems)
            for (final day in item.days) ?day.schoolShift,
        },
      ),
  ];
}

List<Weekday> requestedWeekdays(Iterable<RequestItem> items) {
  final days = {
    for (final item in items)
      for (final day in item.days)
        if (day.needsOutbound || day.needsReturn) day.weekday,
  };
  return [
    for (final weekday in Weekday.values)
      if (days.contains(weekday)) weekday,
  ];
}
