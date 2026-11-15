import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockLoadClientProposals loadClientProposals;
  late MockListClientServiceRequests listServiceRequests;
  late MockWithdrawServiceRequest withdrawServiceRequest;

  final withdrawn = TestClientServiceRequest(
    token: testRequestForLucas.token,
    status: ServiceRequestStatus.withdrawn,
  );
  final olderClosed = TestClientServiceRequest(
    token: 'request-closed-old',
    status: ServiceRequestStatus.expired,
  );

  ClientProposalsState readyWith(
    ClientProposals proposals, {
    String? selectedChildToken,
    ProposalsTab tab = ProposalsTab.open,
  }) {
    return ClientProposalsState(
      status: ClientProposalsStatus.ready,
      proposals: proposals,
      selectedChildToken: selectedChildToken,
      tab: tab,
    );
  }

  setUp(() {
    loadClientProposals = MockLoadClientProposals();
    listServiceRequests = MockListClientServiceRequests();
    withdrawServiceRequest = MockWithdrawServiceRequest();
  });

  ClientProposalsCubit buildCubit() => ClientProposalsCubit(
    loadClientProposals: loadClientProposals,
    listServiceRequests: listServiceRequests,
    withdrawServiceRequest: withdrawServiceRequest,
  );

  void loadReturns(Result<ClientProposalsFailure, ClientProposals> result) {
    when(loadClientProposals.call).thenAnswer((_) async => result);
  }

  group('loading', () {
    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'loads the open negotiations, the closed ones and the children',
      setUp: () => loadReturns(Ok(testClientProposals())),
      build: buildCubit,
      act: (cubit) => cubit.loadProposals(),
      expect: () => [
        const ClientProposalsState(status: ClientProposalsStatus.loading),
        readyWith(testClientProposals()),
      ],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a first load without connection offers to try again',
      setUp: () => loadReturns(const Err(ClientProposalsFailure.network)),
      build: buildCubit,
      act: (cubit) => cubit.loadProposals(),
      expect: () => [
        const ClientProposalsState(status: ClientProposalsStatus.loading),
        const ClientProposalsState(
          status: ClientProposalsStatus.loadFailed,
          failure: ClientProposalsFailure.network,
        ),
      ],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a failed reload keeps what was on screen',
      setUp: () => loadReturns(const Err(ClientProposalsFailure.network)),
      build: buildCubit,
      seed: () => readyWith(testClientProposals()),
      act: (cubit) => cubit.loadProposals(),
      expect: () => <ClientProposalsState>[],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a reload keeps the child and the tab chosen',
      setUp: () => loadReturns(Ok(testClientProposals())),
      build: buildCubit,
      seed: () => readyWith(
        testClientProposals(),
        selectedChildToken: testAna.token,
        tab: ProposalsTab.closed,
      ),
      act: (cubit) => cubit.loadProposals(),
      expect: () => <ClientProposalsState>[],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a reload drops the filter of a child that was removed',
      setUp: () => loadReturns(
        Ok(testClientProposals(children: const [testPedro, testLucas])),
      ),
      build: buildCubit,
      seed: () =>
          readyWith(testClientProposals(), selectedChildToken: testAna.token),
      act: (cubit) => cubit.loadProposals(),
      expect: () => [
        readyWith(testClientProposals(children: const [testPedro, testLucas])),
      ],
    );
  });

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'filters by a child and switches tabs',
    build: buildCubit,
    seed: () => readyWith(testClientProposals()),
    act: (cubit) => cubit
      ..selectChild(testPedro.token)
      ..selectTab(ProposalsTab.closed),
    expect: () => [
      readyWith(testClientProposals(), selectedChildToken: testPedro.token),
      readyWith(
        testClientProposals(),
        selectedChildToken: testPedro.token,
        tab: ProposalsTab.closed,
      ),
    ],
  );

  group('the closed ones of a child', () {
    final secondPage = TestClientServiceRequest(
      token: 'request-closed-page-2',
      status: ServiceRequestStatus.expired,
      items: [testItemFor(testAna)],
    );

    void closedPagesReturn() {
      when(
        () => listServiceRequests(
          statuses: closedServiceRequestStatuses,
          page: 1,
        ),
      ).thenAnswer(
        (_) async => Ok(
          NegotiationPage(
            items: [olderClosed],
            isLast: false,
            totalElements: 4,
          ),
        ),
      );
      when(
        () => listServiceRequests(
          statuses: closedServiceRequestStatuses,
          page: 2,
        ),
      ).thenAnswer(
        (_) async => Ok(
          NegotiationPage(items: [secondPage], isLast: true, totalElements: 4),
        ),
      );
    }

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'filtering by a child loads every closed page, so the count is exact',
      setUp: closedPagesReturn,
      build: buildCubit,
      seed: () => readyWith(testClientProposals(hasMoreClosed: true)),
      act: (cubit) => cubit.selectChild(testAna.token),
      verify: (cubit) {
        final proposals = cubit.state.proposals!;
        expect(proposals.hasMoreClosed, isFalse);
        expect(proposals.closedPage, 2);
        expect(cubit.state.visibleFeed.closed, [testClosedForAna, secondPage]);
        expect(cubit.state.visibleFeed.closedCount, 2);
        expect(cubit.state.isLoadingMoreClosed, isFalse);
      },
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a reload with a child chosen loads every closed page again',
      setUp: () {
        closedPagesReturn();
        loadReturns(Ok(testClientProposals(hasMoreClosed: true)));
      },
      build: buildCubit,
      seed: () =>
          readyWith(testClientProposals(), selectedChildToken: testAna.token),
      act: (cubit) => cubit.loadProposals(),
      verify: (cubit) {
        expect(cubit.state.proposals!.hasMoreClosed, isFalse);
        expect(cubit.state.visibleFeed.closedCount, 2);
      },
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a failed page stops loading and tells why',
      setUp: () => when(
        () => listServiceRequests(
          statuses: closedServiceRequestStatuses,
          page: 1,
        ),
      ).thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
      build: buildCubit,
      seed: () => readyWith(testClientProposals(hasMoreClosed: true)),
      act: (cubit) => cubit.selectChild(testAna.token),
      verify: (cubit) {
        expect(cubit.state.isLoadingMoreClosed, isFalse);
        verify(
          () => listServiceRequests(
            statuses: closedServiceRequestStatuses,
            page: 1,
          ),
        ).called(1);
      },
    );
  });

  group('the closed ones', () {
    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'loads the next page at the end of the list',
      setUp: () =>
          when(
            () => listServiceRequests(
              statuses: closedServiceRequestStatuses,
              page: 1,
            ),
          ).thenAnswer(
            (_) async => Ok(
              NegotiationPage(
                items: [olderClosed],
                isLast: true,
                totalElements: 3,
              ),
            ),
          ),
      build: buildCubit,
      seed: () => readyWith(testClientProposals(hasMoreClosed: true)),
      act: (cubit) => cubit.loadMoreClosed(),
      expect: () => [
        readyWith(testClientProposals(hasMoreClosed: true))
            .copyWith(isLoadingMoreClosed: true),
        readyWith(
          testClientProposals(
            closed: [testClosedForPedro, testClosedForAna, olderClosed],
            closedPage: 1,
          ),
        ),
      ],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'does not ask again after the last page',
      build: buildCubit,
      seed: () => readyWith(testClientProposals()),
      act: (cubit) => cubit.loadMoreClosed(),
      expect: () => <ClientProposalsState>[],
      verify: (_) => verifyNever(
        () => listServiceRequests(
          statuses: any(named: 'statuses'),
          page: any(named: 'page'),
        ),
      ),
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a failed next page keeps the list and tells why',
      setUp: () => when(
        () => listServiceRequests(
          statuses: closedServiceRequestStatuses,
          page: 1,
        ),
      ).thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
      build: buildCubit,
      seed: () => readyWith(testClientProposals(hasMoreClosed: true)),
      act: (cubit) => cubit.loadMoreClosed(),
      skip: 1,
      expect: () => [
        readyWith(testClientProposals(hasMoreClosed: true))
            .copyWith(actionFailure: const NegotiationNetworkFailure()),
      ],
    );
  });

  group('loading more while something else changes the list', () {
    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a page that arrives after a reload is dropped',
      setUp: () {
        final page =
            Completer<
              Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>>
            >();
        when(
          () => listServiceRequests(
            statuses: closedServiceRequestStatuses,
            page: 1,
          ),
        ).thenAnswer((_) => page.future);
        when(loadClientProposals.call).thenAnswer((_) async {
          page.complete(
            Ok(
              NegotiationPage(
                items: [olderClosed],
                isLast: true,
                totalElements: 3,
              ),
            ),
          );
          return Ok(testClientProposals(open: const []));
        });
      },
      build: buildCubit,
      seed: () => readyWith(testClientProposals(hasMoreClosed: true)),
      act: (cubit) async {
        final loadingMore = cubit.loadMoreClosed();
        await cubit.loadProposals();
        await loadingMore;
      },
      verify: (cubit) {
        expect(cubit.state, readyWith(testClientProposals(open: const [])));
      },
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'loading more keeps a cancellation in progress',
      setUp: () =>
          when(
            () => listServiceRequests(
              statuses: closedServiceRequestStatuses,
              page: 1,
            ),
          ).thenAnswer(
            (_) async => Ok(
              NegotiationPage(
                items: [olderClosed],
                isLast: true,
                totalElements: 3,
              ),
            ),
          ),
      build: buildCubit,
      seed: () =>
          readyWith(testClientProposals(hasMoreClosed: true))
              .copyWith(cancellingRequestToken: testRequestForLucas.token),
      act: (cubit) => cubit.loadMoreClosed(),
      verify: (cubit) =>
          expect(cubit.state.cancellingRequestToken, testRequestForLucas.token),
    );
  });

  group('cancelling a request', () {
    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'moves it to the closed ones and reloads the list in the order of the back',
      setUp: () {
        when(() => withdrawServiceRequest(testRequestForLucas.token))
            .thenAnswer((_) async => Ok(withdrawn));
        loadReturns(
          Ok(testClientProposals(closed: [testClosedForPedro, withdrawn])),
        );
      },
      build: buildCubit,
      seed: () => readyWith(testClientProposals()),
      act: (cubit) => cubit.cancelRequest(testRequestForLucas.token),
      expect: () => [
        readyWith(testClientProposals())
            .copyWith(cancellingRequestToken: testRequestForLucas.token),
        readyWith(testClientProposals().withRequestClosed(withdrawn)),
        readyWith(testClientProposals(closed: [testClosedForPedro, withdrawn])),
      ],
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'a request that changed on the other side reloads the list',
      setUp: () {
        when(() => withdrawServiceRequest(testRequestForLucas.token))
            .thenAnswer(
              (_) async => const Err(
                NegotiationConflictFailure(detail: 'O motorista já respondeu.'),
              ),
            );
        loadReturns(Ok(testClientProposals()));
      },
      build: buildCubit,
      seed: () => readyWith(testClientProposals()),
      act: (cubit) => cubit.cancelRequest(testRequestForLucas.token),
      skip: 1,
      expect: () => [
        readyWith(testClientProposals()).copyWith(
          actionFailure: const NegotiationConflictFailure(
            detail: 'O motorista já respondeu.',
          ),
        ),
        readyWith(testClientProposals()),
      ],
      verify: (_) => verify(loadClientProposals.call).called(1),
    );

    blocTest<ClientProposalsCubit, ClientProposalsState>(
      'without connection keeps the request open and tells why',
      setUp: () =>
          when(() => withdrawServiceRequest(testRequestForLucas.token))
              .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
      build: buildCubit,
      seed: () => readyWith(testClientProposals()),
      act: (cubit) => cubit.cancelRequest(testRequestForLucas.token),
      skip: 1,
      expect: () => [
        readyWith(testClientProposals())
            .copyWith(actionFailure: const NegotiationNetworkFailure()),
      ],
      verify: (_) => verifyNever(loadClientProposals.call),
    );
  });
}
