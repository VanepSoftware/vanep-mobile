import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_state.dart';

import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

const networkFailure = DriverStudentNetworkFailure();

void main() {
  late MockFindDriverOccupancy findDriverOccupancy;
  late MockListDriverStudents listDriverStudents;
  late MockInviteStudentFamily inviteStudentFamily;
  late MockFindParentsGroupInvite findParentsGroupInvite;
  late MockMergeStudentFamily mergeStudentFamily;
  late MockDismissStudentFamilyMatch dismissStudentFamilyMatch;

  VanStudentsCubit buildCubit() => VanStudentsCubit(
    vehicleToken: 'van-1',
    findDriverOccupancy: findDriverOccupancy,
    listDriverStudents: listDriverStudents,
    inviteStudentFamily: inviteStudentFamily,
    findParentsGroupInvite: findParentsGroupInvite,
    mergeStudentFamily: mergeStudentFamily,
    dismissStudentFamilyMatch: dismissStudentFamilyMatch,
  );

  void answerStudents(List<DriverStudent> students) {
    when(() => listDriverStudents(vehicleToken: 'van-1'))
        .thenAnswer((_) async => Ok(students));
  }

  final loaded = VanStudentsState(
    status: VanStudentsStatus.loaded,
    students: vanStudents,
    occupancy: studentsOccupancy,
  );

  setUp(() {
    findDriverOccupancy = MockFindDriverOccupancy();
    when(() => findDriverOccupancy())
        .thenAnswer((_) async => const Ok(studentsOccupancy));
    listDriverStudents = MockListDriverStudents();
    inviteStudentFamily = MockInviteStudentFamily();
    findParentsGroupInvite = MockFindParentsGroupInvite();
    mergeStudentFamily = MockMergeStudentFamily();
    dismissStudentFamilyMatch = MockDismissStudentFamilyMatch();
    answerStudents(vanStudents);
  });

  blocTest<VanStudentsCubit, VanStudentsState>(
    'loads the students of the van',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const VanStudentsState(), loaded],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'a failed first load shows the error',
    setUp: () =>
        when(() => listDriverStudents(vehicleToken: 'van-1'))
            .thenAnswer((_) async => const Err(networkFailure)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const VanStudentsState(),
      const VanStudentsState(status: VanStudentsStatus.loadFailed),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'a failed refresh keeps the list',
    setUp: () =>
        when(() => listDriverStudents(vehicleToken: 'van-1'))
            .thenAnswer((_) async => const Err(networkFailure)),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.refresh(),
    expect: () => <VanStudentsState>[],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'filters by family, shift and search',
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit
      ..selectFamilyFilter(StudentFamilyFilter.withoutFamily)
      ..toggleShift(OperationShift.morning)
      ..openSearch()
      ..changeQuery('miguel'),
    verify: (cubit) {
      expect(cubit.state.visibleStudents, [afternoonMiguel]);
      expect(cubit.state.enabledShifts, {OperationShift.afternoon});
    },
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'closing the search clears the query',
    build: buildCubit,
    seed: () => loaded.copyWith(isSearching: true, query: 'ana'),
    act: (cubit) => cubit.closeSearch(),
    verify: (cubit) {
      expect(cubit.state.isSearching, isFalse);
      expect(cubit.state.query, '');
    },
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'inviting asks to share the link with the student name and reloads',
    setUp: () => when(() => inviteStudentFamily('student-1')).thenAnswer(
      (_) async => Ok<DriverStudentFailure, FamilyInvite>(familyInvite),
    ),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.inviteFamily(uninvitedLaura),
    expect: () => [
      loaded.copyWith(busyStudentToken: 'student-1'),
      loaded.copyWith(
        shareRequest: VanStudentsShareRequest(
          inviteUrl: familyInvite.inviteUrl,
          studentName: 'Laura Mendes',
        ),
      ),
    ],
    verify: (_) =>
        verify(() => listDriverStudents(vehicleToken: 'van-1')).called(1),
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'a failed invite shows the failure',
    setUp: () =>
        when(() => inviteStudentFamily('student-1'))
            .thenAnswer((_) async => const Err(networkFailure)),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.inviteFamily(uninvitedLaura),
    expect: () => [
      loaded.copyWith(busyStudentToken: 'student-1'),
      loaded.copyWith(
        notice: const VanStudentsActionFailedNotice(failure: networkFailure),
      ),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'the group link is shared without a student',
    setUp: () => when(() => findParentsGroupInvite()).thenAnswer(
      (_) async => Ok<DriverStudentFailure, FamilyInvite>(familyInvite),
    ),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.shareParentsGroupLink(),
    expect: () => [
      loaded.copyWith(isSharingGroupLink: true),
      loaded.copyWith(
        shareRequest: VanStudentsShareRequest(
          inviteUrl: familyInvite.inviteUrl,
        ),
      ),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'merging announces the dependent name and reloads',
    setUp: () =>
        when(() => mergeStudentFamily('student-rafael'))
            .thenAnswer((_) async => const Ok(null)),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.mergeFamily(joinedRafael),
    expect: () => [
      loaded.copyWith(busyStudentToken: 'student-rafael'),
      loaded.copyWith(
        notice: const VanStudentsMergedNotice(studentName: 'Rafael Costa'),
      ),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'a student without a match is never merged',
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.mergeFamily(uninvitedLaura),
    expect: () => <VanStudentsState>[],
    verify: (_) => verifyNever(() => mergeStudentFamily(any())),
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'dismissing announces it and reloads',
    setUp: () =>
        when(() => dismissStudentFamilyMatch('student-rafael'))
            .thenAnswer((_) async => const Ok(null)),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.dismissFamilyMatch(joinedRafael),
    expect: () => [
      loaded.copyWith(busyStudentToken: 'student-rafael'),
      loaded.copyWith(notice: const VanStudentsDismissedNotice()),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'a second action waits for the first',
    build: buildCubit,
    seed: () => loaded.copyWith(busyStudentToken: 'student-1'),
    act: (cubit) => cubit.dismissFamilyMatch(joinedRafael),
    expect: () => <VanStudentsState>[],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'clears the notice and the share request',
    build: buildCubit,
    seed: () => loaded.copyWith(
      notice: const VanStudentsDismissedNotice(),
      shareRequest: const VanStudentsShareRequest(inviteUrl: 'url'),
    ),
    act: (cubit) => cubit
      ..clearNotice()
      ..clearShareRequest(),
    verify: (cubit) {
      expect(cubit.state.notice, isNull);
      expect(cubit.state.shareRequest, isNull);
    },
  );
  test('progress comes from occupancy rather than the filtered list', () {
    expect(loaded.progress.total, 28);
    expect(loaded.progress.withFamily, 24);
    expect(loaded.progress.percent, 86);
    expect(loaded.copyWith(query: 'nobody').progress, loaded.progress);
  });

  for (final action in ['merge', 'dismiss', 'group']) {
    blocTest<VanStudentsCubit, VanStudentsState>(
      'a failed $action keeps the students and reports the failure',
      setUp: () {
        when(() => mergeStudentFamily(any()))
            .thenAnswer((_) async => const Err(networkFailure));
        when(() => dismissStudentFamilyMatch(any()))
            .thenAnswer((_) async => const Err(networkFailure));
        when(() => findParentsGroupInvite())
            .thenAnswer((_) async => const Err(networkFailure));
      },
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => switch (action) {
        'merge' => cubit.mergeFamily(joinedRafael),
        'dismiss' => cubit.dismissFamilyMatch(joinedRafael),
        _ => cubit.shareParentsGroupLink(),
      },
      verify: (cubit) {
        expect(cubit.state.students, vanStudents);
        expect(
          cubit.state.notice,
          const VanStudentsActionFailedNotice(failure: networkFailure),
        );
        expect(cubit.state.busyStudentToken, isNull);
        expect(cubit.state.isSharingGroupLink, isFalse);
        expect(cubit.state.shareRequest, isNull);
      },
    );
  }

  blocTest<VanStudentsCubit, VanStudentsState>(
    'an occupancy failure fails the initial load instead of inventing progress',
    setUp: () =>
        when(() => findDriverOccupancy())
            .thenAnswer((_) async => const Err(VanCentralFailure.network)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const VanStudentsState(),
      const VanStudentsState(status: VanStudentsStatus.loadFailed),
    ],
  );

  blocTest<VanStudentsCubit, VanStudentsState>(
    'an occupancy refresh failure preserves the last successful snapshot',
    setUp: () =>
        when(() => findDriverOccupancy())
            .thenAnswer((_) async => const Err(VanCentralFailure.network)),
    build: buildCubit,
    seed: () => loaded,
    act: (cubit) => cubit.refresh(),
    expect: () => <VanStudentsState>[],
  );
}
