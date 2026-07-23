import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';

void main() {
  test('AssistantStatus.fromApi maps known API values', () {
    expect(AssistantStatus.fromApi('UNLINKED'), AssistantStatus.unlinked);
    expect(AssistantStatus.fromApi('PENDING'), AssistantStatus.pending);
    expect(AssistantStatus.fromApi('ACTIVE'), AssistantStatus.active);
    expect(AssistantStatus.fromApi('INACTIVE'), AssistantStatus.inactive);
  });

  test('AssistantStatus.fromApi returns null for unknown values', () {
    expect(AssistantStatus.fromApi(null), isNull);
    expect(AssistantStatus.fromApi(''), isNull);
    expect(AssistantStatus.fromApi('OTHER'), isNull);
  });

  test('AssistantStatus.toApi maps enum values', () {
    expect(AssistantStatus.toApi(AssistantStatus.unlinked), 'UNLINKED');
    expect(AssistantStatus.toApi(AssistantStatus.pending), 'PENDING');
    expect(AssistantStatus.toApi(AssistantStatus.active), 'ACTIVE');
    expect(AssistantStatus.toApi(AssistantStatus.inactive), 'INACTIVE');
    expect(AssistantStatus.toApi(null), isNull);
  });
}
