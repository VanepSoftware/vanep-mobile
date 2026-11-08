import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_state.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

import '../../driver_vans/driver_vans_mocks.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../../negotiations/negotiations_mocks.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

const pickup = ClockTime(hour: 12, minute: 5);

const leaveSchool = ClockTime(hour: 18, minute: 0);

ProposalComposerCubit fillValidDraft(ProposalComposerCubit cubit) {
  cubit
    ..changeTotalAmount(744000)
    ..changeInstallments(12)
    ..changeDueDay(10)
    ..changeEndsOn(DateTime(2027, 12, 17))
    ..applyTimeToEveryDay('dep-theo', RouteLeg.outbound, pickup)
    ..applyTimeToEveryDay('dep-theo', RouteLeg.homebound, leaveSchool);
  return cubit;
}

void main() {
  late MockLoadProposalComposer loadComposer;
  late MockListMyVans listMyVans;
  late MockSendProposal sendProposal;

  final request = TestDriverServiceRequest(token: 'request-new');

  setUpAll(registerNegotiationFallbackValues);

  setUp(() {
    loadComposer = MockLoadProposalComposer();
    listMyVans = MockListMyVans();
    sendProposal = MockSendProposal();
  });

  void loadsWith(List<DriverVan> vans, {String? previousProposalToken}) {
    when(
      () => loadComposer(
        'request-new',
        previousProposalToken: previousProposalToken,
      ),
    ).thenAnswer(
      (_) async => Ok(ProposalComposerSetup.from(request: request, vans: vans)),
    );
  }

  ProposalComposerCubit build({String? previousProposalToken}) =>
      ProposalComposerCubit(
        requestToken: 'request-new',
        previousProposalToken: previousProposalToken,
        loadProposalComposer: loadComposer,
        listMyVans: listMyVans,
        sendProposal: sendProposal,
        clock: () => DateTime(2026, 10, 2, 9),
      );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'opens a first proposal from the request with the only van',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      final draft = cubit.state.draft!;
      expect(cubit.state.isReady, isTrue);
      expect(draft.startsOn, request.desiredStartDate);
      expect(draft.vehicleToken, 'van-master');
      expect(draft.validDays, 7);
      expect(cubit.state.canSend, isFalse);
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'a new version reads the previous one',
    setUp: () => loadsWith(const [masterVan], previousProposalToken: 'v1'),
    build: () => build(previousProposalToken: 'v1'),
    act: (cubit) => cubit.load(),
    verify: (_) =>
        verify(() => loadComposer('request-new', previousProposalToken: 'v1'))
            .called(1),
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'with two vans the driver chooses one',
    setUp: () => loadsWith(const [masterVan, sprinterVan]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      cubit.chooseVehicle('van-sprinter');
    },
    verify: (cubit) {
      expect(cubit.state.setup!.choosesVan, isTrue);
      expect(cubit.state.draft!.vehicleToken, 'van-sprinter');
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'without vans nothing can be sent until one is registered',
    setUp: () {
      loadsWith(const []);
      when(() => listMyVans()).thenAnswer((_) async => const Ok([masterVan]));
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      fillValidDraft(cubit);
      expect(cubit.state.canSend, isFalse);
      await cubit.refreshVans();
    },
    verify: (cubit) {
      expect(cubit.state.draft!.vehicleToken, 'van-master');
      expect(cubit.state.canSend, isTrue);
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'the same pickup applies to every day of the leg',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      cubit.applyTimeToEveryDay('dep-theo', RouteLeg.outbound, pickup);
    },
    verify: (cubit) {
      final item = cubit.state.draft!.items.single;
      for (final weekday in weekdaysMondayToFriday) {
        expect(item.timeOf(weekday, RouteLeg.outbound), pickup);
      }
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'turning a leg off removes it from the proposal',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      cubit.toggleLeg('dep-theo', RouteLeg.homebound, Weekday.friday);
    },
    verify: (cubit) => expect(
      cubit.state.draft!.items.single.isEnabled(
        Weekday.friday,
        RouteLeg.homebound,
      ),
      isFalse,
    ),
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'previews the installment with the cents truncated',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      cubit
        ..changeTotalAmount(100000)
        ..changeInstallments(3);
    },
    verify: (cubit) => expect(cubit.state.previewInstallmentCents, 33333),
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'a period over 12 months shows its error and blocks the sending',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) async {
      await cubit.load();
      fillValidDraft(cubit).changeEndsOn(DateTime(2028, 2, 2));
    },
    verify: (cubit) {
      expect(
        cubit.state.visibleErrors,
        contains(ProposalDraftError.periodTooLong),
      );
      expect(cubit.state.canSend, isFalse);
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'missing values block the sending without showing errors',
    setUp: () => loadsWith(const [masterVan]),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.errors, isNotEmpty);
      expect(cubit.state.visibleErrors, isEmpty);
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'sends a valid proposal',
    setUp: () {
      loadsWith(const [masterVan]);
      when(() => sendProposal(any()))
          .thenAnswer((_) async => Ok(TestProposal()));
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await fillValidDraft(cubit).send();
    },
    verify: (cubit) {
      expect(cubit.state.sentProposal, isNotNull);
      final sent =
          verify(() => sendProposal(captureAny())).captured.single
              as ProposalDraft;
      expect(sent.totalAmountCents, 744000);
      expect(sent.items.single.slotsToSend, hasLength(10));
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'a 409 reports the conflict so the negotiation reloads',
    setUp: () {
      loadsWith(const [masterVan]);
      when(() => sendProposal(any())).thenAnswer(
        (_) async => const Err(
          NegotiationConflictFailure(detail: 'O pedido não está mais aberto.'),
        ),
      );
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await fillValidDraft(cubit).send();
    },
    verify: (cubit) =>
        expect(isNegotiationOutdated(cubit.state.failure!), isTrue),
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'a 422 keeps what was filled',
    setUp: () {
      loadsWith(const [masterVan]);
      when(() => sendProposal(any())).thenAnswer(
        (_) async =>
            const Err(NegotiationRejectedFailure(detail: 'Horário inválido.')),
      );
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await fillValidDraft(cubit).send();
    },
    verify: (cubit) {
      expect(cubit.state.failure, isA<NegotiationRejectedFailure>());
      expect(cubit.state.draft!.totalAmountCents, 744000);
      expect(cubit.state.canSend, isTrue);
    },
  );

  blocTest<ProposalComposerCubit, ProposalComposerState>(
    'a failed load offers to try again',
    setUp: () =>
        when(() => loadComposer('request-new'))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) =>
        expect(cubit.state.status, ProposalComposerStatus.loadFailed),
  );
}
