import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/formatters/search_text.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';

class FamilyProgress extends Equatable {
  const FamilyProgress({required this.withFamily, required this.total});

  final int withFamily;

  final int total;

  int get percent => total == 0 ? 0 : (withFamily * 100 / total).round();

  double get ratio => total == 0 ? 0 : withFamily / total;

  @override
  List<Object?> get props => [withFamily, total];
}

Set<OperationShift> shiftsOfStudent(DriverStudent student) {
  return {for (final slot in student.slots) slot.shift};
}

List<OperationShift> shiftsInUse(List<DriverStudent> students) {
  final used = {for (final student in students) ...shiftsOfStudent(student)};
  return [
    for (final shift in OperationShift.values)
      if (used.contains(shift)) shift,
  ];
}

bool isInEnabledShifts(DriverStudent student, Set<OperationShift> enabled) {
  final shifts = shiftsOfStudent(student);
  return shifts.isEmpty || shifts.any(enabled.contains);
}

bool matchesStudentSearch(DriverStudent student, String query) {
  final folded = foldForSearch(query);
  return folded.isEmpty || foldForSearch(student.name).contains(folded);
}

List<DriverStudent> filterVanStudents(
  List<DriverStudent> students, {
  required StudentFamilyFilter familyFilter,
  required Set<OperationShift> enabledShifts,
  required String query,
}) {
  return [
    for (final student in students)
      if (familyFilter.includes(student.familyStatus) &&
          isInEnabledShifts(student, enabledShifts) &&
          matchesStudentSearch(student, query))
        student,
  ];
}

Map<StudentFamilyFilter, int> countByFamilyFilter(
  List<DriverStudent> students, {
  required Set<OperationShift> enabledShifts,
  required String query,
}) {
  return {
    for (final familyFilter in StudentFamilyFilter.values)
      familyFilter: filterVanStudents(
        students,
        familyFilter: familyFilter,
        enabledShifts: enabledShifts,
        query: query,
      ).length,
  };
}

DriverStudent? firstPendingMatch(List<DriverStudent> students) {
  for (final student in students) {
    if (student.familyStatus == FamilyStatus.familyJoined &&
        student.familyMatch != null) {
      return student;
    }
  }
  return null;
}

Set<OperationShift> enabledShiftsOf(
  List<OperationShift> inUse,
  Set<OperationShift> disabled,
) {
  return {
    for (final shift in inUse)
      if (!disabled.contains(shift)) shift,
  };
}

Set<OperationShift> toggleDisabledShift({
  required List<OperationShift> inUse,
  required Set<OperationShift> disabled,
  required OperationShift shift,
}) {
  if (disabled.contains(shift)) return {...disabled}..remove(shift);
  if (enabledShiftsOf(inUse, disabled).length <= 1) return disabled;
  return {...disabled, shift};
}
