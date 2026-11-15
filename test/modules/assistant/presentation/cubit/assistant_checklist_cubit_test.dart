import 'dart:async';

import '../../assistant_checklist_mocks.dart';
import '../../fixtures/assistant_checklist_fixtures.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';

void main() {
  late MockGetActiveTripRoute getActiveTripRoute;
  late MockUpdateChecklistStatus updateChecklistStatus;
  late MockRecordNoShow recordNoShow;

  setUpAll(() {
    registerFallbackValue(BoardingStatus.pending);
    registerFallbackValue(ConfirmationSource.assistant);
    registerFallbackValue(NoShowReason.notifiedByGuardian);
  });

  setUp(() {
    getActiveTripRoute = MockGetActiveTripRoute();
    updateChecklistStatus = MockUpdateChecklistStatus();
    recordNoShow = MockRecordNoShow();
  });

  AssistantChecklistCubit buildCubit() {
    return AssistantChecklistCubit(
      getActiveTripRoute: getActiveTripRoute,
      updateChecklistStatus: updateChecklistStatus,
      recordNoShow: recordNoShow,
    );
  }

  test(
    'unauthorized route load preserves stops and does not revoke access',
    () async {
      when(() => getActiveTripRoute('van-1'))
          .thenAnswer((_) async => const Ok([tStop1]));
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.loadRoute('van-1');
      when(() => getActiveTripRoute('van-1'))
          .thenAnswer((_) async => const Err(AssistantFailure.unauthorized));
      await cubit.loadRoute('van-1');
      expect(cubit.state.stops, [tStop1]);
      expect(cubit.state.isLinkRevoked, isFalse);
      expect(cubit.state.failure, AssistantFailure.unauthorized);
    },
  );

  test('pending students cannot be selected for bulk drop-off', () async {
    when(() => getActiveTripRoute('van-1'))
        .thenAnswer((_) async => const Ok([tStop2]));
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadRoute('van-1');
    cubit.toggleStudentSelection('stu-1');
    expect(cubit.state.selectedStudentTokens, isEmpty);
    await cubit.confirmBulkDropOff();
    verifyZeroInteractions(updateChecklistStatus);
  });

  for (final operation in ['boarding', 'dropOff', 'noShow']) {
    test(
      '$operation ignores a second tap while the request is in flight',
      () async {
        final gate = Completer<void>();
        when(() => getActiveTripRoute('van-1'))
            .thenAnswer((_) async => const Ok([tStop2]));
        when(
          () => updateChecklistStatus(
            vanToken: any(named: 'vanToken'),
            studentTokens: any(named: 'studentTokens'),
            status: any(named: 'status'),
            confirmedBy: any(named: 'confirmedBy'),
          ),
        ).thenAnswer((_) async {
          await gate.future;
          return const Ok(null);
        });
        when(
          () => recordNoShow(
            vanToken: any(named: 'vanToken'),
            studentToken: any(named: 'studentToken'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async {
          await gate.future;
          return const Ok(null);
        });
        final cubit = buildCubit();
        addTearDown(cubit.close);
        await cubit.loadRoute('van-1');
        cubit.selectAllAtStop('stop-2');
        Future<void> invoke() => switch (operation) {
          'boarding' => cubit.confirmBoarding('stu-1'),
          'dropOff' => cubit.confirmBulkDropOff(),
          _ => cubit.markNoShow('stu-1', NoShowReason.notAtLocation),
        };
        final first = invoke();
        final second = invoke();
        gate.complete();
        await Future.wait([first, second]);
        if (operation == 'noShow') {
          verify(
            () => recordNoShow(
              vanToken: 'van-1',
              studentToken: 'stu-1',
              reason: NoShowReason.notAtLocation,
            ),
          ).called(1);
        } else {
          verify(
            () => updateChecklistStatus(
              vanToken: 'van-1',
              studentTokens: any(named: 'studentTokens'),
              status: any(named: 'status'),
              confirmedBy: ConfirmationSource.assistant,
            ),
          ).called(1);
        }
      },
    );
  }
  test(
    'a delayed route response does not overwrite the newly selected van',
    () async {
      final previousRoute =
          Completer<Result<AssistantFailure, List<AssistantTripStop>>>();
      when(() => getActiveTripRoute('van-1'))
          .thenAnswer((_) => previousRoute.future);
      when(() => getActiveTripRoute('van-2'))
          .thenAnswer((_) async => const Ok([tStop2]));
      final cubit = buildCubit();
      addTearDown(cubit.close);
      final first = cubit.loadRoute('van-1');
      await cubit.loadRoute('van-2');
      previousRoute.complete(const Ok([tStop1]));
      await first;
      expect(cubit.state.vanToken, 'van-2');
      expect(cubit.state.stops, [tStop2]);
    },
  );

  test('an in-flight update does not change the next van route', () async {
    final update = Completer<void>();
    when(() => getActiveTripRoute('van-1'))
        .thenAnswer((_) async => const Ok([tStop1]));
    when(() => getActiveTripRoute('van-2'))
        .thenAnswer((_) async => const Ok([tStop1]));
    when(
      () => updateChecklistStatus(
        vanToken: 'van-1',
        studentTokens: ['stu-1'],
        status: BoardingStatus.boarded,
        confirmedBy: ConfirmationSource.assistant,
      ),
    ).thenAnswer((_) async {
      await update.future;
      return const Ok(null);
    });
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadRoute('van-1');
    final first = cubit.confirmBoarding('stu-1');
    await cubit.loadRoute('van-2');
    update.complete();
    await first;
    expect(cubit.state.vanToken, 'van-2');
    expect(cubit.state.isUpdating, isFalse);
    expect(cubit.state.allStudents.single.status, BoardingStatus.pending);
  });

  test(
    'clearing the active van discards an in-flight route response',
    () async {
      final route =
          Completer<Result<AssistantFailure, List<AssistantTripStop>>>();
      when(() => getActiveTripRoute('van-1')).thenAnswer((_) => route.future);
      final cubit = buildCubit();
      addTearDown(cubit.close);
      final pending = cubit.loadRoute('van-1');
      cubit.clearRoute();
      route.complete(const Ok([tStop1]));
      await pending;
      expect(cubit.state, const AssistantChecklistState());
    },
  );

  group('AssistantChecklistCubit', () {
    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'loadRoute emits stops and calculates counts when successful',
      build: () {
        when(() => getActiveTripRoute('van-1'))
            .thenAnswer((_) async => const Ok([tStop1, tStop2]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoute('van-1'),
      expect: () => [
        const AssistantChecklistState(isLoading: true, vanToken: 'van-1'),
        const AssistantChecklistState(
          isLoading: false,
          vanToken: 'van-1',
          stops: [tStop1, tStop2],
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.totalCount, 2);
        expect(cubit.state.completedCount, 1);
      },
    );

    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'loadRoute sets isLinkRevoked when revokedInvite failure occurs',
      build: () {
        when(() => getActiveTripRoute('van-1'))
            .thenAnswer((_) async => const Err(AssistantFailure.revokedInvite));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoute('van-1'),
      expect: () => [
        const AssistantChecklistState(isLoading: true, vanToken: 'van-1'),
        const AssistantChecklistState(
          isLoading: false,
          vanToken: 'van-1',
          isLinkRevoked: true,
          failure: AssistantFailure.revokedInvite,
        ),
      ],
    );

    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'confirmBoarding updates student status to boarded with assistant attribution',
      build: () {
        when(
          () => updateChecklistStatus(
            vanToken: 'van-1',
            studentTokens: ['stu-1'],
            status: BoardingStatus.boarded,
            confirmedBy: ConfirmationSource.assistant,
          ),
        ).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      seed: () =>
          const AssistantChecklistState(vanToken: 'van-1', stops: [tStop1]),
      act: (cubit) => cubit.confirmBoarding('stu-1'),
      expect: () => [
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop1],
          isUpdating: true,
        ),
        const AssistantChecklistState(
          vanToken: 'van-1',
          isUpdating: false,
          stops: [
            AssistantTripStop(
              id: 'stop-1',
              order: 1,
              title: 'Parada Residencial',
              address: 'Rua das Flores, 100',
              isSchool: false,
              items: [
                AssistantChecklistItem(
                  studentToken: 'stu-1',
                  studentName: 'Ana Clara',
                  schoolName: 'Colégio São Bento',
                  stopId: 'stop-1',
                  stopAddress: 'Rua das Flores, 100',
                  status: BoardingStatus.boarded,
                  confirmedBy: ConfirmationSource.assistant,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'selectAllAtStop and confirmBulkDropOff marks selected students as droppedOff',
      build: () {
        when(
          () => updateChecklistStatus(
            vanToken: 'van-1',
            studentTokens: any(named: 'studentTokens'),
            status: BoardingStatus.droppedOff,
            confirmedBy: ConfirmationSource.assistant,
          ),
        ).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      seed: () =>
          const AssistantChecklistState(vanToken: 'van-1', stops: [tStop2]),
      act: (cubit) async {
        cubit.selectAllAtStop('stop-2');
        await cubit.confirmBulkDropOff();
      },
      expect: () => [
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop2],
          selectedStudentTokens: {'stu-2'},
        ),
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop2],
          selectedStudentTokens: {'stu-2'},
          isUpdating: true,
        ),
        const AssistantChecklistState(
          vanToken: 'van-1',
          isUpdating: false,
          selectedStudentTokens: {},
          stops: [
            AssistantTripStop(
              id: 'stop-2',
              order: 2,
              title: 'Colégio São Bento',
              address: 'Av. Paulista, 500',
              isSchool: true,
              items: [
                tStudent1,
                AssistantChecklistItem(
                  studentToken: 'stu-2',
                  studentName: 'Bruno Lima',
                  schoolName: 'Colégio São Bento',
                  stopId: 'stop-2',
                  stopAddress: 'Av. Paulista, 500',
                  status: BoardingStatus.droppedOff,
                  confirmedBy: ConfirmationSource.assistant,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'markNoShow records no-show reason and assistant attribution',
      build: () {
        when(
          () => recordNoShow(
            vanToken: 'van-1',
            studentToken: 'stu-1',
            reason: NoShowReason.notifiedByGuardian,
          ),
        ).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      seed: () =>
          const AssistantChecklistState(vanToken: 'van-1', stops: [tStop1]),
      act: (cubit) =>
          cubit.markNoShow('stu-1', NoShowReason.notifiedByGuardian),
      expect: () => [
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop1],
          isUpdating: true,
        ),
        const AssistantChecklistState(
          vanToken: 'van-1',
          isUpdating: false,
          stops: [
            AssistantTripStop(
              id: 'stop-1',
              order: 1,
              title: 'Parada Residencial',
              address: 'Rua das Flores, 100',
              isSchool: false,
              items: [
                AssistantChecklistItem(
                  studentToken: 'stu-1',
                  studentName: 'Ana Clara',
                  schoolName: 'Colégio São Bento',
                  stopId: 'stop-1',
                  stopAddress: 'Rua das Flores, 100',
                  status: BoardingStatus.noShow,
                  confirmedBy: ConfirmationSource.assistant,
                  noShowReason: NoShowReason.notifiedByGuardian,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    test('filteredStudents filters by searchQuery and statusFilter', () {
      const state = AssistantChecklistState(
        stops: [tStop2],
        searchQuery: 'bruno',
        statusFilter: BoardingStatus.boarded,
      );

      expect(state.filteredStudents, [tStudent2]);
    });
  });
}
