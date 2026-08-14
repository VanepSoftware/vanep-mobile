import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/email_change_sheet.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/personal_data_gender_chips.dart';

import '../auth_fixtures.dart';
import 'auth_presentation_mocks.dart';

Widget personalDataHarness(PersonalDataCubit cubit) {
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
      child: const PersonalDataPage(),
    ),
  );
}

PersonalDataState readyState({
  FakeUserProfile profile = const FakeUserProfile(),
  String? draftName,
  String? draftPhone,
  Gender? draftGender,
  Map<String, ProfileErrorCode> fieldErrors = const {},
}) {
  return stateFromProfile(profile, status: PersonalDataStatus.ready).copyWith(
    draftName: draftName,
    draftPhone: draftPhone,
    draftGender: draftGender,
    fieldErrors: fieldErrors,
  );
}

void main() {
  late MockPersonalDataCubit cubit;

  setUp(() {
    cubit = MockPersonalDataCubit();
    when(() => cubit.state).thenReturn(readyState());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(cubit.close).thenAnswer((_) async {});
  });

  testWidgets('shows editable fields and disabled save when clean', (
    tester,
  ) async {
    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Ana Motorista'), findsOneWidget);
    expect(find.text('Telefone'), findsOneWidget);
    expect(find.text('(11) 99999-9999'), findsOneWidget);
    expect(find.text('Documento'), findsOneWidget);
    expect(find.text('123.456.789-01'), findsOneWidget);
    expect(find.text('15/05/1990'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(PersonalDataGenderChips),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(PersonalDataGenderChips), findsOneWidget);
    expect(find.text('Feminino'), findsOneWidget);

    final saveButton = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('shows pending email banner and blocks email tap', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      readyState(
        profile: const FakeUserProfile(pendingEmail: 'novo@vanep.com.br'),
      ),
    );

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    expect(
      find.text('Confirme o novo e-mail enviado para novo@vanep.com.br.'),
      findsOneWidget,
    );

    await tester.tap(find.text('ana@vanep.com.br'));
    await tester.pumpAndSettle();

    expect(find.byType(EmailChangeSheet), findsNothing);
  });

  testWidgets('disables name field when cooldown is active', (tester) async {
    when(() => cubit.state).thenReturn(
      readyState(
        profile: FakeUserProfile(
          nameChangeAvailableAt: DateTime(2026, 9, 1, 10),
        ),
      ),
    );

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    expect(find.textContaining('dias'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('masks the phone field while typing', (tester) async {
    when(() => cubit.state).thenReturn(readyState(draftPhone: ''));

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    await tester.enterText(find.byType(TextField).last, '11988887777');
    await tester.pump();

    expect(find.text('(11) 98888-7777'), findsOneWidget);
    verify(() => cubit.updatePhone('(11) 98888-7777')).called(1);
  });

  testWidgets('limits the name field to 255 characters', (tester) async {
    when(() => cubit.state).thenReturn(readyState());

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    expect(nameField.maxLength, 255);
  });

  testWidgets('enables save when state is dirty', (tester) async {
    when(() => cubit.state).thenReturn(
      readyState(draftName: 'Maria'),
    );

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    final saveButton = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('opens email change sheet when email value is tapped', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(readyState());

    await tester.pumpWidget(personalDataHarness(cubit));
    await tester.pump();

    await tester.tap(find.text('ana@vanep.com.br'));
    await tester.pumpAndSettle();

    expect(find.byType(EmailChangeSheet), findsOneWidget);
    expect(find.text('Alterar e-mail'), findsWidgets);
  });
}
