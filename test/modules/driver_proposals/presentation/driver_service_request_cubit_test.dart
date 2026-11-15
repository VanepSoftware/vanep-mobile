import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  group('DriverServiceRequestCubit', () {
    late MockFindDriverServiceRequest findRequest;

    setUp(() => findRequest = MockFindDriverServiceRequest());

    DriverServiceRequestCubit build() => DriverServiceRequestCubit(
      requestToken: 'request-new',
      findServiceRequest: findRequest,
    );

    blocTest<DriverServiceRequestCubit, DriverServiceRequestState>(
      'loads the request and can answer while it is open',
      setUp: () =>
          when(() => findRequest('request-new'))
              .thenAnswer((_) async => Ok(newRequestForSiblings)),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const DriverServiceRequestState(
          status: DriverServiceRequestStatus.loading,
        ),
        DriverServiceRequestState(
          status: DriverServiceRequestStatus.ready,
          request: newRequestForSiblings,
        ),
      ],
      verify: (cubit) => expect(cubit.state.canAnswer, isTrue),
    );

    blocTest<DriverServiceRequestCubit, DriverServiceRequestState>(
      'a request already answered cannot be answered again',
      setUp: () => when(() => findRequest('request-new')).thenAnswer(
        (_) async =>
            Ok(TestDriverServiceRequest(status: ServiceRequestStatus.answered)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.canAnswer, isFalse),
    );

    blocTest<DriverServiceRequestCubit, DriverServiceRequestState>(
      'a request that no longer exists is not found',
      setUp: () =>
          when(() => findRequest('request-new'))
              .thenAnswer((_) async => const Err(NegotiationNotFoundFailure())),
      build: build,
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [
        const DriverServiceRequestState(
          status: DriverServiceRequestStatus.notFound,
        ),
      ],
    );

    blocTest<DriverServiceRequestCubit, DriverServiceRequestState>(
      'a failed reload keeps the request on screen',
      setUp: () =>
          when(() => findRequest('request-new'))
              .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
      build: build,
      seed: () => DriverServiceRequestState(
        status: DriverServiceRequestStatus.ready,
        request: newRequestForSiblings,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        DriverServiceRequestState(
          status: DriverServiceRequestStatus.ready,
          request: newRequestForSiblings,
          actionFailure: const NegotiationNetworkFailure(),
        ),
      ],
    );
  });

  group('RequestDeclineCubit', () {
    late MockDeclineServiceRequest declineRequest;

    setUp(() => declineRequest = MockDeclineServiceRequest());

    RequestDeclineCubit build() => RequestDeclineCubit(
      requestToken: 'request-new',
      declineServiceRequest: declineRequest,
    );

    final declined = TestDriverServiceRequest(
      token: 'request-new',
      status: ServiceRequestStatus.declined,
    );

    blocTest<RequestDeclineCubit, RequestDeclineState>(
      'declines without a reason',
      setUp: () =>
          when(() => declineRequest('request-new'))
              .thenAnswer((_) async => Ok(declined)),
      build: build,
      act: (cubit) => cubit.send(),
      expect: () => [
        const RequestDeclineState(isSending: true),
        RequestDeclineState(declinedRequest: declined),
      ],
    );

    blocTest<RequestDeclineCubit, RequestDeclineState>(
      'sends the reason trimmed',
      setUp: () =>
          when(() => declineRequest('request-new', reason: 'Sem vaga'))
              .thenAnswer((_) async => Ok(declined)),
      build: build,
      act: (cubit) async {
        cubit.changeReason('  Sem vaga ');
        await cubit.send();
      },
      verify: (_) =>
          verify(() => declineRequest('request-new', reason: 'Sem vaga'))
              .called(1),
    );

    blocTest<RequestDeclineCubit, RequestDeclineState>(
      'a reason over 500 characters cannot be sent',
      build: build,
      act: (cubit) async {
        cubit.changeReason('a' * 501);
        await cubit.send();
      },
      verify: (cubit) {
        expect(cubit.state.canSend, isFalse);
        verifyNever(() => declineRequest(any(), reason: any(named: 'reason')));
      },
    );

    blocTest<RequestDeclineCubit, RequestDeclineState>(
      'a 409 reports the conflict so the request reloads',
      setUp: () => when(() => declineRequest('request-new')).thenAnswer(
        (_) async => const Err(
          NegotiationConflictFailure(detail: 'O pedido não está mais aberto.'),
        ),
      ),
      build: build,
      act: (cubit) => cubit.send(),
      skip: 1,
      expect: () => [
        const RequestDeclineState(
          failure: NegotiationConflictFailure(
            detail: 'O pedido não está mais aberto.',
          ),
        ),
      ],
    );
  });
}
