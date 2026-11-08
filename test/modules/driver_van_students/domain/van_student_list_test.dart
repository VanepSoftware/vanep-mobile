import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/van_student_list.dart';

import '../driver_van_students_fixtures.dart';

const bothShifts = {OperationShift.morning, OperationShift.afternoon};

void main() {
  group('filterVanStudents', () {
    test('the family filter splits students with and without family', () {
      final withFamily = filterVanStudents(
        vanStudents,
        familyFilter: StudentFamilyFilter.withFamily,
        enabledShifts: bothShifts,
        query: '',
      );
      final withoutFamily = filterVanStudents(
        vanStudents,
        familyFilter: StudentFamilyFilter.withoutFamily,
        enabledShifts: bothShifts,
        query: '',
      );

      expect(withFamily, [contractedBruno]);
      expect(withoutFamily, [
        uninvitedLaura,
        invitedSofia,
        joinedRafael,
        afternoonMiguel,
      ]);
    });

    test('a student stays while any of its shifts is enabled', () {
      final morningOnly = filterVanStudents(
        vanStudents,
        familyFilter: StudentFamilyFilter.all,
        enabledShifts: {OperationShift.morning},
        query: '',
      );

      expect(morningOnly, isNot(contains(afternoonMiguel)));
      expect(morningOnly, contains(uninvitedLaura));
    });

    test('the search ignores case and accents', () {
      final found = filterVanStudents(
        [studentFixture(name: 'Sofía Lima'), uninvitedLaura],
        familyFilter: StudentFamilyFilter.all,
        enabledShifts: bothShifts,
        query: ' SOFIA ',
      );

      expect(found.single.name, 'Sofía Lima');
    });
  });

  test('counts follow the shift filter and the search', () {
    final counts = countByFamilyFilter(
      vanStudents,
      enabledShifts: {OperationShift.morning},
      query: '',
    );

    expect(counts, {
      StudentFamilyFilter.all: 4,
      StudentFamilyFilter.withFamily: 1,
      StudentFamilyFilter.withoutFamily: 3,
    });
  });

  test('shifts in use come in the shift order', () {
    expect(shiftsInUse([afternoonMiguel, uninvitedLaura]), [
      OperationShift.morning,
      OperationShift.afternoon,
    ]);
  });

  test('the first pending match is the family that joined', () {
    expect(firstPendingMatch(vanStudents), joinedRafael);
    expect(firstPendingMatch([uninvitedLaura]), isNull);
  });

  test('progress rounds occupancy numbers and handles an empty total', () {
    const progress = FamilyProgress(withFamily: 24, total: 28);
    expect(progress.percent, 86);
    expect(progress.ratio, closeTo(24 / 28, 0.001));
    expect(const FamilyProgress(withFamily: 0, total: 0).percent, 0);
  });

  group('toggleDisabledShift', () {
    const inUse = [OperationShift.morning, OperationShift.afternoon];

    test('disables and enables a shift', () {
      final disabled = toggleDisabledShift(
        inUse: inUse,
        disabled: const {},
        shift: OperationShift.morning,
      );

      expect(disabled, {OperationShift.morning});
      expect(
        toggleDisabledShift(
          inUse: inUse,
          disabled: disabled,
          shift: OperationShift.morning,
        ),
        isEmpty,
      );
    });

    test('never disables the last enabled shift', () {
      expect(
        toggleDisabledShift(
          inUse: inUse,
          disabled: {OperationShift.morning},
          shift: OperationShift.afternoon,
        ),
        {OperationShift.morning},
      );
    });
  });
}
