import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/email_change_sheet.dart';

import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockRefreshUserProfile refreshUserProfile;
  late MockPatchUserProfile patchUserProfile;
  late MockRequestEmailChange requestEmailChange;
  late PersonalDataCubit cubit;

  setUpAll(registerAuthFallbacks);

  setUp(() async {
    refreshUserProfile = MockRefreshUserProfile();
    patchUserProfile = MockPatchUserProfile();
    requestEmailChange = MockRequestEmailChange();
    when(refreshUserProfile.call).thenAnswer(
      (_) async => const Ok<ProfileEditFailure, UserProfile>(
        FakeUserProfile(),
      ),
    );
    cubit = PersonalDataCubit(
      refreshUserProfile: refreshUserProfile,
      patchUserProfile: patchUserProfile,
      requestEmailChange: requestEmailChange,
      syncProfile: (_) {},
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  Widget harness() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider<PersonalDataCubit>.value(
        value: cubit,
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showEmailChangeSheet(context),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets(
    'shows success confirmation and closes sheet when continue is tapped',
    (tester) async {
      when(() => requestEmailChange('novo@vanep.com.br')).thenAnswer(
        (_) async => const Ok<ProfileEditFailure, UserProfile>(
          FakeUserProfile(pendingEmail: 'novo@vanep.com.br'),
        ),
      );

      await tester.pumpWidget(harness());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'novo@vanep.com.br',
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(VanepPrimaryButton, 'Alterar e-mail'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verifique seu e-mail'), findsOneWidget);
      expect(
        find.textContaining(
          'Enviamos um link de confirmação para novo@vanep.com.br',
        ),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.widgetWithText(VanepPrimaryButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.byType(EmailChangeSheet), findsNothing);
    },
  );
}
