import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockListDriverServiceRequests listRequests;

  setUp(() {
    listRequests = MockListDriverServiceRequests();
  });

  DriverNegotiationsCubit build() => DriverNegotiationsCubit(
    listServiceRequests: listRequests,
    clock: () => driverNow,
  );

  blocTest<DriverNegotiationsCubit, DriverNegotiationsState>(
    'loads the open negotiations grouped by whose turn it is',
    setUp: () => when(() => listRequests(statuses: openServiceRequestStatuses))
        .thenAnswer(
          (_) async => Ok(
            driverPage([
              awaitingRequest,
              newRequestForSiblings,
              adjustmentRequest,
            ]),
          ),
        ),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      final negotiations = cubit.state.negotiations!;
      expect(cubit.state.status, DriverNegotiationsStatus.ready);
      expect(negotiations.pending, [newRequestForSiblings, adjustmentRequest]);
      expect(negotiations.awaiting, [awaitingRequest]);
      expect(negotiations.totalCount, 3);
    },
  );

  blocTest<DriverNegotiationsCubit, DriverNegotiationsState>(
    'a failure on the first load offers to try again',
    setUp: () =>
        when(() => listRequests(statuses: openServiceRequestStatuses))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DriverNegotiationsState(status: DriverNegotiationsStatus.loading),
      const DriverNegotiationsState(
        status: DriverNegotiationsStatus.loadFailed,
      ),
    ],
  );

  blocTest<DriverNegotiationsCubit, DriverNegotiationsState>(
    'pulling to refresh keeps the list when it fails',
    setUp: () =>
        when(() => listRequests(statuses: openServiceRequestStatuses))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: build,
    seed: () => DriverNegotiationsState(
      status: DriverNegotiationsStatus.ready,
      negotiations: driverNegotiationsOf([newRequestForSiblings]),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      DriverNegotiationsState(
        status: DriverNegotiationsStatus.ready,
        negotiations: driverNegotiationsOf([newRequestForSiblings]),
        actionFailure: const NegotiationNetworkFailure(),
      ),
    ],
  );

  blocTest<DriverNegotiationsCubit, DriverNegotiationsState>(
    'loads the next page at the end of the list',
    setUp: () {
      when(() => listRequests(statuses: openServiceRequestStatuses)).thenAnswer(
        (_) async => Ok(
          driverPage([newRequestForSiblings], isLast: false, totalElements: 2),
        ),
      );
      when(() => listRequests(statuses: openServiceRequestStatuses, page: 1))
          .thenAnswer(
            (_) async => Ok(driverPage([awaitingRequest], totalElements: 2)),
          );
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
      await cubit.loadMore();
    },
    verify: (cubit) {
      expect(cubit.state.negotiations!.requests, [
        newRequestForSiblings,
        awaitingRequest,
      ]);
      verify(() => listRequests(statuses: openServiceRequestStatuses, page: 1))
          .called(1);
    },
  );

  blocTest<DriverNegotiationsCubit, DriverNegotiationsState>(
    'contracts are a segment of their own',
    build: build,
    act: (cubit) => cubit.selectSegment(DriverProposalsSegment.contracts),
    expect: () => [
      const DriverNegotiationsState(segment: DriverProposalsSegment.contracts),
    ],
  );
}
