import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_state.dart';

import '../dependents_mocks.dart';

void main() {
  late MockFindSchoolDays findSchoolDays;

  final week = SchoolWeek.fromDays(const [
    SchoolDay(weekday: Weekday.monday, shift: SchoolShift.morning),
    SchoolDay(weekday: Weekday.thursday, shift: SchoolShift.fullTime),
  ]);

  setUp(() {
    findSchoolDays = MockFindSchoolDays();
  });

  DependentDetailCubit buildCubit() => DependentDetailCubit(
    dependentToken: 'dep-helena',
    findSchoolDays: findSchoolDays,
  );

  void schoolDaysReturn(Result<DependentFailure, SchoolWeek> result) {
    when(() => findSchoolDays(any())).thenAnswer((_) async => result);
  }

  test('starts loading the week', () {
    expect(buildCubit().state.isLoading, isTrue);
  });

  blocTest<DependentDetailCubit, DependentDetailState>(
    'loading lands on the week of the dependent',
    setUp: () => schoolDaysReturn(Ok(week)),
    build: buildCubit,
    act: (cubit) => cubit.loadSchoolWeek(),
    expect: () => [
      const DependentDetailState(),
      DependentDetailState(status: DependentDetailStatus.loaded, week: week),
    ],
    verify: (_) {
      verify(() => findSchoolDays('dep-helena')).called(1);
    },
  );

  blocTest<DependentDetailCubit, DependentDetailState>(
    'a failed load can be retried',
    setUp: () {
      final results = <Result<DependentFailure, SchoolWeek>>[
        const Err(DependentNetworkFailure()),
        Ok(week),
      ];
      when(() => findSchoolDays(any()))
          .thenAnswer((_) async => results.removeAt(0));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadSchoolWeek();
      await cubit.loadSchoolWeek();
    },
    expect: () => [
      const DependentDetailState(),
      const DependentDetailState(status: DependentDetailStatus.loadFailed),
      const DependentDetailState(),
      DependentDetailState(status: DependentDetailStatus.loaded, week: week),
    ],
  );

  blocTest<DependentDetailCubit, DependentDetailState>(
    'applySavedWeek swaps in the week the editor saved',
    seed: () =>
        DependentDetailState(status: DependentDetailStatus.loaded, week: week),
    build: buildCubit,
    act: (cubit) => cubit.applySavedWeek(const SchoolWeek.empty()),
    expect: () => [
      const DependentDetailState(
        status: DependentDetailStatus.loaded,
        week: SchoolWeek.empty(),
      ),
    ],
  );
}
