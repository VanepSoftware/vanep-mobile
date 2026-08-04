import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';

import '../profile_fixtures.dart';
import '../profile_mocks.dart';

void main() {
  late MockGetProfileSummary getProfileSummary;

  setUpAll(() {
    registerFallbackValue(UserType.client);
  });

  setUp(() {
    getProfileSummary = MockGetProfileSummary();
  });

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'loadSummaryIfNeeded emits loaded without fetch for admin',
    build: () => ProfileSummaryCubit(getProfileSummary: getProfileSummary),
    act: (cubit) => cubit.loadSummaryIfNeeded(UserType.admin),
    expect: () => const [
      ProfileSummaryState(status: ProfileSummaryStatus.loaded),
    ],
    verify: (_) {
      verifyNever(() => getProfileSummary(any()));
    },
  );

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'loadSummaryIfNeeded emits loading then loaded with summary',
    build: () {
      when(
        () => getProfileSummary(UserType.client),
      ).thenAnswer((_) async => const Ok(testClientSummaryDto));
      return ProfileSummaryCubit(getProfileSummary: getProfileSummary);
    },
    act: (cubit) => cubit.loadSummaryIfNeeded(UserType.client),
    expect: () => [
      const ProfileSummaryState(status: ProfileSummaryStatus.loading),
      const ProfileSummaryState(
        status: ProfileSummaryStatus.loaded,
        summary: testClientSummaryDto,
      ),
    ],
  );

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'loadSummaryIfNeeded soft-fails to loaded without summary',
    build: () {
      when(() => getProfileSummary(UserType.driver)).thenAnswer(
        (_) async => const Err(NetworkProfileSummaryFailure('offline')),
      );
      return ProfileSummaryCubit(getProfileSummary: getProfileSummary);
    },
    act: (cubit) => cubit.loadSummaryIfNeeded(UserType.driver),
    expect: () => [
      const ProfileSummaryState(status: ProfileSummaryStatus.loading),
      const ProfileSummaryState(
        status: ProfileSummaryStatus.loaded,
        failure: NetworkProfileSummaryFailure('offline'),
      ),
    ],
  );

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'loadSummaryIfNeeded is a no-op after the first load',
    build: () {
      when(
        () => getProfileSummary(UserType.client),
      ).thenAnswer((_) async => const Ok(testClientSummaryDto));
      return ProfileSummaryCubit(getProfileSummary: getProfileSummary);
    },
    act: (cubit) async {
      await cubit.loadSummaryIfNeeded(UserType.client);
      await cubit.loadSummaryIfNeeded(UserType.client);
    },
    expect: () => [
      const ProfileSummaryState(status: ProfileSummaryStatus.loading),
      const ProfileSummaryState(
        status: ProfileSummaryStatus.loaded,
        summary: testClientSummaryDto,
      ),
    ],
    verify: (_) {
      verify(() => getProfileSummary(UserType.client)).called(1);
    },
  );

  test('state exposes rating for client and driver; city only for driver', () {
    const driverState = ProfileSummaryState(
      status: ProfileSummaryStatus.loaded,
      summary: testDriverSummaryDto,
    );
    const clientState = ProfileSummaryState(
      status: ProfileSummaryStatus.loaded,
      summary: testClientSummaryDto,
    );
    const assistantState = ProfileSummaryState(
      status: ProfileSummaryStatus.loaded,
      summary: testAssistantSummaryDto,
    );

    expect(driverState.rating, 4.8);
    expect(driverState.city, 'São Paulo');
    expect(driverState.assistantStatus, isNull);

    expect(clientState.rating, 4.5);
    expect(clientState.city, isNull);
    expect(clientState.assistantStatus, isNull);

    expect(assistantState.rating, isNull);
    expect(assistantState.city, isNull);
    expect(assistantState.assistantStatus, AssistantStatus.pending);
  });
}
