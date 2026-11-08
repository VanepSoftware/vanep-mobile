import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/create_unlinked_passenger.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/dismiss_student_family_match.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/find_parents_group_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/invite_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/list_driver_students.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/merge_student_family.dart';

import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

void main() {
  late MockDriverStudentRepository repository;

  setUp(() => repository = MockDriverStudentRepository());

  test('ListDriverStudents passes the van through', () async {
    when(() => repository.listStudents(vehicleToken: 'van-1')).thenAnswer(
      (_) async => Ok<DriverStudentFailure, List<DriverStudent>>(vanStudents),
    );

    final result = await ListDriverStudents(repository)(vehicleToken: 'van-1');

    expect(result.valueOrNull, vanStudents);
  });

  test(
    'InviteStudentFamily and FindParentsGroupInvite answer the invite',
    () async {
      final ok = Ok<DriverStudentFailure, FamilyInvite>(familyInvite);
      when(() => repository.inviteFamily('rafa')).thenAnswer((_) async => ok);
      when(() => repository.findParentsGroupInvite())
          .thenAnswer((_) async => ok);

      expect(await InviteStudentFamily(repository)('rafa'), ok);
      expect(await FindParentsGroupInvite(repository)(), ok);
    },
  );

  test(
    'MergeStudentFamily and DismissStudentFamilyMatch pass the token',
    () async {
      const ok = Ok<DriverStudentFailure, void>(null);
      when(() => repository.mergeFamily('rafa')).thenAnswer((_) async => ok);
      when(() => repository.dismissFamilyMatch('rafa'))
          .thenAnswer((_) async => ok);

      expect(await MergeStudentFamily(repository)('rafa'), ok);
      expect(await DismissStudentFamilyMatch(repository)('rafa'), ok);
    },
  );

  test('CreateUnlinkedPassenger answers the new token', () async {
    final draft = completeDraft();
    when(() => repository.createUnlinkedPassenger(draft))
        .thenAnswer((_) async => const Ok('new'));

    expect(
      (await CreateUnlinkedPassenger(repository)(draft)).valueOrNull,
      'new',
    );
  });
}
