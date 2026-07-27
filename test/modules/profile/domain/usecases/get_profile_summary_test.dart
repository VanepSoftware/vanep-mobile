import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';

import '../../profile_fixtures.dart';
import '../../profile_mocks.dart';

void main() {
  late MockProfileSummaryRepository repository;
  late GetProfileSummary getProfileSummary;

  setUp(() {
    repository = MockProfileSummaryRepository();
    getProfileSummary = GetProfileSummary(repository);
  });

  test('delegates to repository', () async {
    when(
      () => repository.fetchSummary(UserType.client),
    ).thenAnswer((_) async => const Ok(testProfileSummaryDto));

    final result = await getProfileSummary(UserType.client);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, testProfileSummaryDto);
    verify(() => repository.fetchSummary(UserType.client)).called(1);
  });
}
