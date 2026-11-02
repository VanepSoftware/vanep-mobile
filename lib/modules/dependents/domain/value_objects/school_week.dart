import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

const SchoolShift fallbackSchoolShift = SchoolShift.morning;

class SchoolDay extends Equatable {
  const SchoolDay({required this.weekday, required this.shift});

  final Weekday weekday;
  final SchoolShift shift;

  @override
  List<Object?> get props => [weekday, shift];
}

class SchoolWeek extends Equatable {
  const SchoolWeek.empty() : shiftsByDay = const {};

  SchoolWeek.fromDays(Iterable<SchoolDay> days)
    : shiftsByDay = Map.unmodifiable({
        for (final day in days) day.weekday: day.shift,
      });

  final Map<Weekday, SchoolShift> shiftsByDay;

  bool get isEmpty => shiftsByDay.isEmpty;

  int get dayCount => shiftsByDay.length;

  bool isOn(Weekday day) => shiftsByDay.containsKey(day);

  SchoolShift? shiftOf(Weekday day) => shiftsByDay[day];

  List<SchoolDay> get days => [
    for (final day in Weekday.values)
      if (shiftsByDay[day] case final shift?)
        SchoolDay(weekday: day, shift: shift),
  ];

  SchoolWeek turnOn(Weekday day) {
    if (isOn(day)) return this;
    return withShift(day, findDefaultShift(shiftsByDay, day));
  }

  SchoolWeek turnOff(Weekday day) {
    if (!isOn(day)) return this;
    return SchoolWeek.fromDays(days.where((entry) => entry.weekday != day));
  }

  SchoolWeek changeShift(Weekday day, SchoolShift shift) {
    if (!isOn(day)) return this;
    return withShift(day, shift);
  }

  SchoolWeek withShift(Weekday day, SchoolShift shift) {
    return SchoolWeek.fromDays([
      ...days.where((entry) => entry.weekday != day),
      SchoolDay(weekday: day, shift: shift),
    ]);
  }

  @override
  List<Object?> get props => [shiftsByDay];
}

SchoolShift findDefaultShift(
  Map<Weekday, SchoolShift> shiftsByDay,
  Weekday day,
) {
  final earlier = Weekday.values.sublist(0, day.index).reversed;
  final later = Weekday.values.sublist(day.index + 1);
  for (final candidate in [...earlier, ...later]) {
    final shift = shiftsByDay[candidate];
    if (shift != null) return shift;
  }
  return fallbackSchoolShift;
}
