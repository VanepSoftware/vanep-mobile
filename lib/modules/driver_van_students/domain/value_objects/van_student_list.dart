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

class VanStudentSummary extends Equatable {
  const VanStudentSummary({
    required this.shifts,
    required this.enabledShifts,
    required this.visibleStudents,
    required this.counts,
    required this.progress,
    required this.pendingMatch,
  });

  final List<OperationShift> shifts;
  final Set<OperationShift> enabledShifts;
  final List<DriverStudent> visibleStudents;
  final Map<StudentFamilyFilter, int> counts;
  final FamilyProgress progress;
  final DriverStudent? pendingMatch;

  @override
  List<Object?> get props => [
    shifts,
    enabledShifts,
    visibleStudents,
    counts,
    progress,
    pendingMatch,
  ];
}

VanStudentSummary summarizeVanStudents(
  List<DriverStudent> students, {
  required StudentFamilyFilter familyFilter,
  required Set<OperationShift> disabledShifts,
  required String query,
}) {
  final shifts = shiftsInUse(students);
  final enabledShifts = enabledShiftsOf(shifts, disabledShifts);
  final counts = {for (final filter in StudentFamilyFilter.values) filter: 0};
  final visibleStudents = <DriverStudent>[];
  for (final student in students) {
    if (!isInEnabledShifts(student, enabledShifts)) continue;
    if (!matchesStudentSearch(student, query)) continue;
    for (final filter in StudentFamilyFilter.values) {
      if (filter.includes(student.familyStatus)) {
        counts[filter] = counts[filter]! + 1;
      }
    }
    if (familyFilter.includes(student.familyStatus)) {
      visibleStudents.add(student);
    }
  }
  return VanStudentSummary(
    shifts: shifts,
    enabledShifts: enabledShifts,
    visibleStudents: visibleStudents,
    counts: counts,
    progress: familyProgressOf(students),
    pendingMatch: firstPendingMatch(students),
  );
}

Map<StudentFamilyFilter, int> countByFamilyFilter(
  List<DriverStudent> students, {
  required Set<OperationShift> enabledShifts,
  required String query,
}) {
  return summarizeVanStudents(
    students,
    familyFilter: StudentFamilyFilter.all,
    disabledShifts: {
      for (final shift in shiftsInUse(students))
        if (!enabledShifts.contains(shift)) shift,
    },
    query: query,
  ).counts;
}

FamilyProgress familyProgressOf(List<DriverStudent> students) {
  return FamilyProgress(
    withFamily: [
      for (final student in students)
        if (student.familyStatus == FamilyStatus.withFamily) student,
    ].length,
    total: students.length,
  );
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

Set<OperationShift> reconcileDisabledShifts(
  List<OperationShift> inUse,
  Set<OperationShift> disabled,
) {
  final stillDisabled = disabled.intersection(inUse.toSet());
  if (inUse.isNotEmpty && stillDisabled.length == inUse.length) return {};
  return stillDisabled;
}
