import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_slots.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/shell_personal_data_slots.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/profile/profile_mocks.dart';

void main() {
  late MockProfileSummaryCubit summary;

  setUpAll(() => registerFallbackValue(UserType.client));

  setUp(() {
    summary = MockProfileSummaryCubit();
    whenListen(
      summary,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    when(() => summary.loadSummaryIfNeeded(any())).thenAnswer((_) async {});
  });

  Future<PersonalDataSlots> slotsFor(WidgetTester tester, UserType type) async {
    late PersonalDataSlots slots;
    await tester.pumpWidget(
      BlocProvider<ProfileSummaryCubit>.value(
        value: summary,
        child: Builder(
          builder: (context) {
            slots = buildShellPersonalDataSlots(
              context,
              FakeUserProfile(type: type),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return slots;
  }

  testWidgets(
    'a driver edits only the profile photo; vans live in the vans tab',
    (tester) async {
      final slots = await slotsFor(tester, UserType.driver);

      expect(slots.header, isNotNull);
      expect(slots.footer, isEmpty);
      verify(() => summary.loadSummaryIfNeeded(UserType.driver)).called(1);
    },
  );

  testWidgets('a client edits only the profile photo', (tester) async {
    final slots = await slotsFor(tester, UserType.client);

    expect(slots.header, isNotNull);
    expect(slots.footer, isEmpty);
  });

  testWidgets('an admin has no profile photo to edit', (tester) async {
    final slots = await slotsFor(tester, UserType.admin);

    expect(slots.header, isNull);
    expect(slots.footer, isEmpty);
  });
}
