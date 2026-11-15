import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../conversations_mocks.dart';

typedef ClientTimelineState = NegotiationTimelineState<ClientServiceRequest>;

void main() {
  late MockFindConversationNegotiation findNegotiation;

  final negotiation = ConversationNegotiation<ClientServiceRequest>(
    request: TestClientServiceRequest(),
    versions: [TestProposal()],
  );

  setUp(() => findNegotiation = MockFindConversationNegotiation());

  NegotiationTimelineCubit<ClientServiceRequest> buildCubit() =>
      NegotiationTimelineCubit(
        conversationToken: 'conversation-1',
        findNegotiation: findNegotiation,
      );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'reads the negotiation of the conversation',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => Ok(negotiation)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const ClientTimelineState(status: NegotiationTimelineStatus.loading),
      ClientTimelineState(
        status: NegotiationTimelineStatus.ready,
        negotiation: negotiation,
      ),
    ],
  );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'an old conversation without a negotiation shows nothing of it',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => const Ok(null)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const ClientTimelineState(status: NegotiationTimelineStatus.loading),
      const ClientTimelineState(status: NegotiationTimelineStatus.none),
    ],
  );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'a first load that fails says so instead of hiding the negotiation',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const ClientTimelineState(status: NegotiationTimelineStatus.loading),
      const ClientTimelineState(status: NegotiationTimelineStatus.loadFailed),
    ],
  );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'trying again after a failure loads the negotiation',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => Ok(negotiation)),
    build: buildCubit,
    seed: () =>
        const ClientTimelineState(status: NegotiationTimelineStatus.loadFailed),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ClientTimelineState(status: NegotiationTimelineStatus.loading),
      ClientTimelineState(
        status: NegotiationTimelineStatus.ready,
        negotiation: negotiation,
      ),
    ],
  );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'a reload that fails keeps the negotiation already on screen',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: buildCubit,
    seed: () => ClientTimelineState(
      status: NegotiationTimelineStatus.ready,
      negotiation: negotiation,
    ),
    act: (cubit) => cubit.load(),
    expect: () => <ClientTimelineState>[],
  );

  blocTest<NegotiationTimelineCubit<ClientServiceRequest>, ClientTimelineState>(
    'reloading after an action keeps the negotiation on screen meanwhile',
    setUp: () =>
        when(() => findNegotiation('conversation-1'))
            .thenAnswer((_) async => Ok(negotiation)),
    build: buildCubit,
    seed: () => ClientTimelineState(
      status: NegotiationTimelineStatus.ready,
      negotiation: ConversationNegotiation(
        request: TestClientServiceRequest(token: 'request-old'),
        versions: const [],
      ),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      ClientTimelineState(
        status: NegotiationTimelineStatus.ready,
        negotiation: negotiation,
      ),
    ],
  );
}
