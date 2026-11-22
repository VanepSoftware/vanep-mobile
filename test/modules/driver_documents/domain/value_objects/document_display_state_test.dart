import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';

void main() {
  test('states compare by value', () {
    expect(
      const DocumentExpiringSoon(daysLeft: 9),
      const DocumentExpiringSoon(daysLeft: 9),
    );
    expect(
      const DocumentExpiringSoon(daysLeft: 9),
      isNot(const DocumentExpiringSoon(daysLeft: 8)),
    );
    expect(
      const DocumentNotSent(isOptional: true),
      isNot(const DocumentNotSent(isOptional: false)),
    );
  });

  test('only the states that wait for the driver need action', () {
    const needAction = <DocumentDisplayState>[
      DocumentNotSent(isOptional: false),
      DocumentNotSent(isOptional: true),
      DocumentRejected(),
      DocumentExpired(),
      DocumentExpiringSoon(daysLeft: 3),
    ];
    const waitForVanep = <DocumentDisplayState>[
      DocumentUnderReview(),
      DocumentRenewalUnderReview(),
      DocumentApproved(),
    ];

    expect(needAction.every((state) => state.needsAction), isTrue);
    expect(waitForVanep.any((state) => state.needsAction), isFalse);
  });
}
