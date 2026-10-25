import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_state.dart';

import '../dependents_mocks.dart';

void main() {
  late MockFindSchoolDays findSchoolDays;
  late MockReplaceSchoolDays replaceSchoolDays;

  final mondayMorning = SchoolWeek.fromDays(const [
    SchoolDay(weekday: Weekday.monday, shift: SchoolShift.morning),
  ]);

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    findSchoolDays = MockFindSchoolDays();
    replaceSchoolDays = MockReplaceSchoolDays();
  });

  DependentSchoolDaysCubit buildCubit() => DependentSchoolDaysCubit(
    dependentToken: 'dep-pedro',
    findSchoolDays: findSchoolDays,
    replaceSchoolDays: replaceSchoolDays,
  );

  DependentSchoolDaysState editing(SchoolWeek loaded, [SchoolWeek? week]) {
    return DependentSchoolDaysState(
      status: DependentSchoolDaysStatus.editing,
      loaded: loaded,
      week: week ?? loaded,
    );
  }

  void replaceReturns(Result<DependentFailure, SchoolWeek> result) {
    when(
      () => replaceSchoolDays(
        dependentToken: any(named: 'dependentToken'),
        week: any(named: 'week'),
      ),
    ).thenAnswer((_) async => result);
  }

  group('loading', () {
    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'lands on the loaded week, ready to edit',
      setUp: () {
        when(() => findSchoolDays(any()))
            .thenAnswer((_) async => Ok(mondayMorning));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const DependentSchoolDaysState(), editing(mondayMorning)],
      verify: (cubit) {
        verify(() => findSchoolDays('dep-pedro')).called(1);
        expect(cubit.state.canSave, isFalse);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'an empty week starts from Monday to Friday in the morning',
      setUp: () {
        when(() => findSchoolDays(any()))
            .thenAnswer((_) async => const Ok(SchoolWeek.empty()));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const DependentSchoolDaysState(),
        editing(const SchoolWeek.empty(), suggestedSchoolWeek),
      ],
      verify: (cubit) {
        expect(cubit.state.week.dayCount, 5);
        expect(cubit.state.week.isOn(Weekday.saturday), isFalse);
        expect(
          cubit.state.week.days.map((day) => day.shift).toSet(),
          {SchoolShift.morning},
        );
        expect(cubit.state.canSave, isTrue);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'a failure leaves nothing to edit and can be retried',
      setUp: () {
        final results = <Result<DependentFailure, SchoolWeek>>[
          const Err(DependentNetworkFailure()),
          Ok(mondayMorning),
        ];
        when(() => findSchoolDays(any()))
            .thenAnswer((_) async => results.removeAt(0));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        expect(cubit.state.hasLoadFailed, isTrue);
        await cubit.load();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentSchoolDaysStatus.editing);
        expect(cubit.state.week, mondayMorning);
      },
    );
  });

  group('editing', () {
    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'turning a day on takes the shift of the closest day before it',
      seed: () => editing(
        mondayMorning.changeShift(Weekday.monday, SchoolShift.afternoon),
      ),
      build: buildCubit,
      act: (cubit) => cubit.turnOn(Weekday.tuesday),
      verify: (cubit) {
        expect(
          cubit.state.week.shiftOf(Weekday.tuesday),
          SchoolShift.afternoon,
        );
        expect(cubit.state.week.dayCount, 2);
        expect(cubit.state.canSave, isTrue);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'the first day turned on is in the morning',
      seed: () => editing(const SchoolWeek.empty()),
      build: buildCubit,
      act: (cubit) => cubit.turnOn(Weekday.wednesday),
      verify: (cubit) {
        expect(
          cubit.state.week.shiftOf(Weekday.wednesday),
          SchoolShift.morning,
        );
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'changing a shift touches only that day',
      seed: () => editing(mondayMorning.turnOn(Weekday.thursday)),
      build: buildCubit,
      act: (cubit) => cubit.changeShift(Weekday.thursday, SchoolShift.fullTime),
      verify: (cubit) {
        expect(
          cubit.state.week.shiftOf(Weekday.thursday),
          SchoolShift.fullTime,
        );
        expect(cubit.state.week.shiftOf(Weekday.monday), SchoolShift.morning);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'undoing every change disables saving again',
      seed: () => editing(mondayMorning),
      build: buildCubit,
      act: (cubit) => cubit
        ..turnOff(Weekday.monday)
        ..turnOn(Weekday.monday),
      verify: (cubit) {
        expect(cubit.state.week, mondayMorning);
        expect(cubit.state.canSave, isFalse);
      },
    );
  });

  group('saving', () {
    final savedWeek = mondayMorning.turnOn(Weekday.friday);

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'puts the edited week and hands back the saved one',
      setUp: () => replaceReturns(Ok(savedWeek)),
      seed: () => editing(mondayMorning),
      build: buildCubit,
      act: (cubit) async {
        cubit.turnOn(Weekday.friday);
        await cubit.save();
      },
      verify: (cubit) {
        verify(
          () => replaceSchoolDays(dependentToken: 'dep-pedro', week: savedWeek),
        ).called(1);
        expect(cubit.state.status, DependentSchoolDaysStatus.saved);
        expect(cubit.state.week, savedWeek);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'an empty week can be saved to clear the schedule',
      setUp: () => replaceReturns(const Ok(SchoolWeek.empty())),
      seed: () => editing(mondayMorning),
      build: buildCubit,
      act: (cubit) async {
        cubit.turnOff(Weekday.monday);
        await cubit.save();
      },
      verify: (cubit) {
        verify(
          () => replaceSchoolDays(
            dependentToken: 'dep-pedro',
            week: const SchoolWeek.empty(),
          ),
        ).called(1);
        expect(cubit.state.status, DependentSchoolDaysStatus.saved);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'a failure keeps the edits and shows the failure',
      setUp: () => replaceReturns(const Err(DependentValidationFailure())),
      seed: () => editing(mondayMorning),
      build: buildCubit,
      act: (cubit) async {
        cubit.turnOn(Weekday.friday);
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentSchoolDaysStatus.editing);
        expect(cubit.state.week, savedWeek);
        expect(cubit.state.failure, const DependentValidationFailure());
        expect(cubit.state.canSave, isTrue);
      },
    );

    blocTest<DependentSchoolDaysCubit, DependentSchoolDaysState>(
      'nothing is sent while the week equals the loaded one',
      seed: () => editing(mondayMorning),
      build: buildCubit,
      act: (cubit) => cubit.save(),
      verify: (_) {
        verifyNever(
          () => replaceSchoolDays(
            dependentToken: any(named: 'dependentToken'),
            week: any(named: 'week'),
          ),
        );
      },
    );
  });
}
