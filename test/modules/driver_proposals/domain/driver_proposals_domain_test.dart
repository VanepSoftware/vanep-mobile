import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_negotiations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../driver_proposals_fixtures.dart';

void main() {
  group('DriverNegotiations', () {
    test('new requests and adjustments are pending, the rest awaits', () {
      final negotiations = driverNegotiationsOf([
        awaitingRequest,
        newRequestForSiblings,
        adjustmentRequest,
      ]);

      expect(negotiations.pending, [newRequestForSiblings, adjustmentRequest]);
      expect(negotiations.awaiting, [awaitingRequest]);
    });

    test('a closed request is in neither group', () {
      final negotiations = driverNegotiationsOf([
        TestDriverServiceRequest(status: ServiceRequestStatus.declined),
      ]);

      expect(negotiations.isEmpty, isTrue);
    });

    test('the next page adds what is new and keeps the first load time', () {
      final first = DriverNegotiations.fromFirstPage(
        driverPage([newRequestForSiblings], isLast: false, totalElements: 2),
        loadedAt: driverNow,
      );

      final next = first.withNextPage(
        driverPage([newRequestForSiblings, awaitingRequest], totalElements: 2),
        page: 1,
      );

      expect(next.requests, [newRequestForSiblings, awaitingRequest]);
      expect(next.page, 1);
      expect(next.hasMore, isFalse);
      expect(next.loadedAt, driverNow);
    });
  });

  group('DriverProposalDetail', () {
    test('the pending adjustment is the latest of the open version', () {
      final detail = DriverProposalDetail(
        request: adjustmentRequest,
        proposal: versionWithAdjustment,
      );

      expect(detail.pendingAdjustment, versionWithAdjustment.adjustments.last);
    });

    test('there is no pending adjustment while the family decides', () {
      final detail = DriverProposalDetail(
        request: awaitingRequest,
        proposal: versionWithAdjustment,
      );

      expect(detail.pendingAdjustment, isNull);
    });

    test('a superseded version is not open', () {
      final detail = DriverProposalDetail(
        request: adjustmentRequest,
        proposal: supersededVersion,
      );

      expect(detail.isOpen, isFalse);
      expect(detail.pendingAdjustment, isNull);
    });
  });

  group('resolveProposalVehicle', () {
    test('a single van is chosen without asking', () {
      expect(resolveProposalVehicle(null, [masterVan]), 'van-master');
    });

    test('with two vans the driver chooses', () {
      expect(resolveProposalVehicle(null, [masterVan, sprinterVan]), isNull);
    });

    test('the van of the previous version stays when it still exists', () {
      expect(
        resolveProposalVehicle('van-sprinter', [masterVan, sprinterVan]),
        'van-sprinter',
      );
    });

    test('a removed van asks for another one', () {
      expect(
        resolveProposalVehicle('van-gone', [masterVan, sprinterVan]),
        isNull,
      );
    });
  });

  group('ProposalComposerSetup', () {
    test('a first proposal starts on the desired start date', () {
      final setup = ProposalComposerSetup.from(
        request: newRequestForSiblings,
        vans: const [masterVan],
      );

      expect(setup.draft.startsOn, newRequestForSiblings.desiredStartDate);
      expect(setup.draft.items, hasLength(2));
      expect(setup.draft.vehicleToken, 'van-master');
      expect(setup.draft.validDays, 7);
    });

    test('a new version comes with the values of the previous one', () {
      final setup = ProposalComposerSetup.from(
        request: adjustmentRequest,
        vans: const [masterVan, sprinterVan],
        previousVersion: TestProposal(
          serviceRequestToken: 'request-adjust',
          installments: 10,
        ),
      );

      expect(setup.draft.installments, 10);
      expect(setup.draft.totalAmountCents, 408000);
      expect(setup.draft.vehicleToken, 'van-master');
      expect(setup.choosesVan, isTrue);
    });

    test('without vans the setup says so', () {
      final setup = ProposalComposerSetup.from(
        request: newRequestForSiblings,
        vans: const [],
      );

      expect(setup.hasNoVan, isTrue);
      expect(setup.draft.vehicleToken, isNull);
    });

    test('new vans keep a valid choice', () {
      final setup = ProposalComposerSetup.from(
        request: newRequestForSiblings,
        vans: const [],
      ).withVans(const [sprinterVan]);

      expect(setup.draft.vehicleToken, 'van-sprinter');
    });
  });
}
