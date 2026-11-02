import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';

import '../driver_van_central_fixtures.dart';

void main() {
  test('only an active assistant works in the van', () {
    expect(testAssistants.map((assistant) => assistant.isWorking), [
      isTrue,
      isFalse,
    ]);
  });

  test('splits the team into working and waiting for the invite', () {
    expect(testAssistants.working.map((assistant) => assistant.token), [
      'assistant-1',
    ]);
    expect(testAssistants.pendingCount, 1);
  });
}
