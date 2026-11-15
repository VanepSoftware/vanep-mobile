import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/negotiation_payloads.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/service_request_dto.dart';

import '../negotiation_json_fixtures.dart';

void main() {
  group('a page of requests', () {
    test('reads the items, the end and the total', () {
      final page = readPage(
        pageJson([clientServiceRequestJson()], last: false, totalElements: 21),
        ClientServiceRequestDto.fromJson,
      );

      expect(page.items.single.token, 'request-1');
      expect(page.isLast, isFalse);
      expect(page.totalElements, 21);
    });

    test('without the content is unreadable', () {
      expect(
        () => readPage(
          pageJson([])..remove('content'),
          ClientServiceRequestDto.fromJson,
        ),
        throwsFormatException,
      );
    });

    test('without the end is unreadable', () {
      expect(
        () => readPage(
          pageJson([])..remove('last'),
          ClientServiceRequestDto.fromJson,
        ),
        throwsFormatException,
      );
    });

    test('without the total is unreadable', () {
      expect(
        () => readPage(
          pageJson([])..remove('totalElements'),
          ClientServiceRequestDto.fromJson,
        ),
        throwsFormatException,
      );
    });

    test('with an item that is not an object is unreadable', () {
      expect(
        () => readPage(
          pageJson([])..['content'] = ['request-1'],
          ClientServiceRequestDto.fromJson,
        ),
        throwsFormatException,
      );
    });
  });

  group('the versions of a proposal', () {
    test('reads every version in the order of the back', () {
      final versions = readProposalVersions([proposalJson(), proposalJson()]);

      expect(versions, hasLength(2));
    });

    test('with a version that is not an object is unreadable', () {
      expect(
        () => readProposalVersions([proposalJson(), 'proposal-v2']),
        throwsFormatException,
      );
    });
  });
}
