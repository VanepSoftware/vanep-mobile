import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_active_trip_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/record_no_show.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/update_checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';

class MockGetActiveTripRoute extends Mock implements GetActiveTripRoute {}

class MockUpdateChecklistStatus extends Mock implements UpdateChecklistStatus {}

class MockRecordNoShow extends Mock implements RecordNoShow {}

const tStudent1 = AssistantChecklistItem(
  studentToken: 'stu-1',
  studentName: 'Ana Clara',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-1',
  stopAddress: 'Rua das Flores, 100',
  status: BoardingStatus.pending,
);

const tStudent2 = AssistantChecklistItem(
  studentToken: 'stu-2',
  studentName: 'Bruno Lima',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-2',
  stopAddress: 'Av. Paulista, 500',
  status: BoardingStatus.boarded,
  confirmedBy: ConfirmationSource.driver,
);

const tStop1 = AssistantTripStop(
  id: 'stop-1',
  order: 1,
  title: 'Parada Residencial',
  address: 'Rua das Flores, 100',
  isSchool: false,
  items: [tStudent1],
);

const tStop2 = AssistantTripStop(
  id: 'stop-2',
  order: 2,
  title: 'Colégio São Bento',
  address: 'Av. Paulista, 500',
  isSchool: true,
  items: [tStudent1, tStudent2],
);

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

  group('AssistantChecklistCubit', () {
    blocTest<AssistantChecklistCubit, AssistantChecklistState>(
      'loadRoute emits stops and calculates counts when successful',
      build: () {
        when(
          () => getActiveTripRoute('van-1'),
        ).thenAnswer((_) async => const Ok([tStop1, tStop2]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoute('van-1'),
      expect: () => [
        const AssistantChecklistState(
          isLoading: true,
          vanToken: 'van-1',
        ),
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
        when(
          () => getActiveTripRoute('van-1'),
        ).thenAnswer((_) async => const Err(AssistantFailure.revokedInvite));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRoute('van-1'),
      expect: () => [
        const AssistantChecklistState(
          isLoading: true,
          vanToken: 'van-1',
        ),
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
      seed: () => const AssistantChecklistState(
        vanToken: 'van-1',
        stops: [tStop1],
      ),
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
      seed: () => const AssistantChecklistState(
        vanToken: 'van-1',
        stops: [tStop2],
      ),
      act: (cubit) async {
        cubit.selectAllAtStop('stop-2');
        await cubit.confirmBulkDropOff();
      },
      expect: () => [
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop2],
          selectedStudentTokens: {'stu-1', 'stu-2'},
        ),
        const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tStop2],
          selectedStudentTokens: {'stu-1', 'stu-2'},
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
                AssistantChecklistItem(
                  studentToken: 'stu-1',
                  studentName: 'Ana Clara',
                  schoolName: 'Colégio São Bento',
                  stopId: 'stop-1',
                  stopAddress: 'Rua das Flores, 100',
                  status: BoardingStatus.droppedOff,
                  confirmedBy: ConfirmationSource.assistant,
                ),
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
      seed: () => const AssistantChecklistState(
        vanToken: 'van-1',
        stops: [tStop1],
      ),
      act: (cubit) => cubit.markNoShow(
        'stu-1',
        NoShowReason.notifiedByGuardian,
      ),
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
