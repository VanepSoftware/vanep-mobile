import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_read_only_field.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/email_change_sheet.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/personal_address_card.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../auth_fixtures.dart';
import '../personal_address_fixture.dart';
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

Finder fieldOf(String label) {
  return find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(VanepTextField),
    ),
    matching: find.byType(TextField),
  );
}

PersonalDataState pageState({
  FakeUserProfile profile = const FakeUserProfile(),
  String? draftName,
  String? draftPhone,
  Gender? draftGender,
  bool clearDraftGender = false,
  PersonalDataStatus status = PersonalDataStatus.ready,
  Object? address,
}) {
  return stateFromProfile(
    profile,
    status: status,
    address: address == null ? null : fakePersonalAddress(),
  ).copyWith(
    draftName: draftName,
    draftPhone: draftPhone,
    draftGender: draftGender,
    clearDraftGender: clearDraftGender,
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  late MockPersonalDataCubit cubit;

  setUp(() {
    cubit = MockPersonalDataCubit();
    when(() => cubit.state).thenReturn(pageState());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(cubit.close).thenAnswer((_) async {});
    when(cubit.clearFeedback).thenReturn(null);
    when(() => cubit.updateGender(any())).thenReturn(null);
    when(() => cubit.updatePhone(any())).thenReturn(null);
    when(() => cubit.updateName(any())).thenReturn(null);
    when(cubit.save).thenAnswer((_) async {});
    when(cubit.clearAddress).thenAnswer((_) async {});
    when(cubit.refreshStates).thenAnswer((_) async {});
  });

  group('identity', () {
    testWidgets('uses the new chrome on a white background', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(VanepAppBar), findsOneWidget);
      expect(find.byType(VanepBottomBar), findsOneWidget);
    });

    testWidgets('only the address card has a border, the fields do not', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(VanepOutlinedPanel), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PersonalAddressCard),
          matching: find.byType(VanepOutlinedPanel),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(PersonalDataFields),
          matching: find.byType(VanepOutlinedPanel),
        ),
        findsNothing,
      );
    });

    testWidgets('shows a title and a subtitle in the body', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final header = tester.widget<VanepPageHeader>(
        find.byType(VanepPageHeader),
      );
      expect(header.title, 'Dados pessoais');
      expect(
        header.subtitle,
        'Confira e atualize os dados da sua conta e o endereço da sua casa.',
      );
      expect(find.text(header.title), findsOneWidget);
      expect(find.text(header.subtitle), findsOneWidget);
    });

    testWidgets('the app bar carries no title of its own', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(
        tester.widget<VanepAppBar>(find.byType(VanepAppBar)).title,
        isNull,
      );
    });

    testWidgets('the header scrolls with the content, above the first field', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(VanepPageHeader),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byType(VanepPageHeader)).dy,
        lessThan(tester.getTopLeft(find.text('Nome')).dy),
      );
    });

    testWidgets('a pending e-mail banner comes after the header', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(
        pageState(
          profile: const FakeUserProfile(pendingEmail: 'novo@vanep.app'),
        ),
      );
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(
        tester.getTopLeft(find.byType(VanepPageHeader)).dy,
        lessThan(tester.getTopLeft(find.byType(PendingEmailBanner)).dy),
      );
    });

    testWidgets('shows account fields with the label above each one', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      for (final label in [
        'Nome',
        'E-mail',
        'Telefone',
        'Documento',
        'Data de nascimento',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Ana Motorista'), findsOneWidget);
      expect(find.text('(11) 99999-9999'), findsOneWidget);
      expect(find.text('123.456.789-01'), findsOneWidget);
      expect(find.text('15/05/1990'), findsOneWidget);
    });

    testWidgets('document and birth date are read-only and disabled', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final documentField = tester.widget<TextField>(fieldOf('Documento'));
      final birthField = tester.widget<TextField>(
        fieldOf('Data de nascimento'),
      );
      expect(documentField.enabled, isFalse);
      expect(birthField.enabled, isFalse);
      expect(find.byType(VanepReadOnlyField), findsNWidgets(3));
    });
  });

  group('gender', () {
    testWidgets('is a select with four options and no chips', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(VanepGenderSelect), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);

      await tester.tap(find.byType(DropdownButton<Gender?>));
      await tester.pumpAndSettle();

      for (final label in [
        'Masculino',
        'Feminino',
        'Outro',
        'Prefiro não informar',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('choosing Prefiro não informar asks the cubit for null', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      await tester.tap(find.byType(DropdownButton<Gender?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prefiro não informar').last);
      await tester.pumpAndSettle();

      verify(() => cubit.updateGender(null)).called(1);
    });

    testWidgets('an omitted gender shows Prefiro não informar', (tester) async {
      useTallScreen(tester);
      when(
        () => cubit.state,
      ).thenReturn(pageState(profile: const FakeUserProfile(gender: null)));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.text('Prefiro não informar'), findsOneWidget);
    });
  });

  group('editing', () {
    testWidgets('save is disabled when nothing changed', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final save = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(save.onPressed, isNull);
    });

    testWidgets('save is enabled when the profile is dirty', (tester) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(draftName: 'Maria'));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final save = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(save.onPressed, isNotNull);
    });

    testWidgets('an address-only edit does not enable this save', (
      tester,
    ) async {
      useTallScreen(tester);
      when(
        () => cubit.state,
      ).thenReturn(pageState().copyWith(addressDraft: fakeCompleteDraft()));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final save = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(save.onPressed, isNull);
    });

    testWidgets('masks the phone field while typing', (tester) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(draftPhone: ''));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      await tester.enterText(fieldOf('Telefone'), '11988887777');
      await tester.pump();

      expect(find.text('(11) 98888-7777'), findsOneWidget);
      verify(() => cubit.updatePhone('(11) 98888-7777')).called(1);
    });

    testWidgets('limits the name field to 255 characters', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(tester.widget<TextField>(fieldOf('Nome')).maxLength, 255);
    });

    testWidgets('disables the name field while the cooldown is active', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(
        pageState(
          profile: FakeUserProfile(
            nameChangeAvailableAt: DateTime.now().add(const Duration(days: 30)),
          ),
        ),
      );

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(tester.widget<TextField>(fieldOf('Nome')).enabled, isFalse);
      expect(find.textContaining('dias'), findsOneWidget);
    });

    testWidgets('the cooldown badge sits on the label row, at the input end', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(
        pageState(
          profile: FakeUserProfile(
            nameChangeAvailableAt: DateTime.now().add(const Duration(days: 30)),
          ),
        ),
      );

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      final label = tester.getRect(find.text('Nome'));
      final badge = tester.getRect(find.byType(CooldownBadge));
      final input = tester.getRect(fieldOf('Nome'));
      expect(badge.center.dy, closeTo(label.center.dy, 1));
      expect(badge.right, closeTo(input.right, 1));
      expect(badge.bottom, lessThanOrEqualTo(input.top));
    });

    testWidgets('there is no badge when no field is on cooldown', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(CooldownBadge), findsNothing);
    });
  });

  group('e-mail', () {
    testWidgets('shows the pending banner and blocks the e-mail tap', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(
        pageState(
          profile: const FakeUserProfile(pendingEmail: 'novo@vanep.com.br'),
        ),
      );

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(
        find.text('Confirme o novo e-mail enviado para novo@vanep.com.br.'),
        findsOneWidget,
      );
      await tester.tap(find.text('ana@vanep.com.br'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(EmailChangeSheet), findsNothing);
    });

    testWidgets('opens the change sheet when the e-mail is tapped', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      await tester.tap(find.text('ana@vanep.com.br'));
      await tester.pumpAndSettle();

      expect(find.byType(EmailChangeSheet), findsOneWidget);
      expect(find.text('Alterar e-mail'), findsWidgets);
    });
  });

  group('address card', () {
    testWidgets(
      'without a house shows the empty state and the register action',
      (tester) async {
        useTallScreen(tester);
        await tester.pumpWidget(personalDataHarness(cubit));
        await tester.pump();

        expect(find.text('Nenhum endereço cadastrado.'), findsOneWidget);
        expect(find.text('Cadastrar endereço'), findsOneWidget);
        expect(
          find.byType(PopupMenuButton<PersonalAddressCardAction>),
          findsNothing,
        );
      },
    );

    testWidgets('the register action opens the address page', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      await tester.tap(find.text('Cadastrar endereço'));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalAddressFormPage), findsOneWidget);
    });

    testWidgets('a saved house shows its summary and no inline postal fields', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(address: true));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.text('QND 12, 10, Casa 2'), findsOneWidget);
      expect(find.text('Taguatinga · Brasília/DF · 72120-120'), findsOneWidget);
      expect(find.text('Cadastrar endereço'), findsNothing);
      expect(find.text('CEP'), findsNothing);
    });

    testWidgets('the menu edit opens the address page', (tester) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(address: true));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.tap(find.byType(PopupMenuButton<PersonalAddressCardAction>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar endereço'));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalAddressFormPage), findsOneWidget);
    });

    testWidgets('clearing confirms first and then asks the cubit', (
      tester,
    ) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(address: true));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.tap(find.byType(PopupMenuButton<PersonalAddressCardAction>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar endereço'));
      await tester.pumpAndSettle();

      expect(find.text('Limpar endereço?'), findsOneWidget);
      verifyNever(cubit.clearAddress);

      await tester.tap(find.text('Limpar').last);
      await tester.pumpAndSettle();

      verify(cubit.clearAddress).called(1);
    });

    testWidgets('cancelling the confirmation keeps the house', (tester) async {
      useTallScreen(tester);
      when(() => cubit.state).thenReturn(pageState(address: true));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.tap(find.byType(PopupMenuButton<PersonalAddressCardAction>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar endereço'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(cubit.clearAddress);
    });

    testWidgets('saving the profile never clears the house', (tester) async {
      useTallScreen(tester);
      when(
        () => cubit.state,
      ).thenReturn(pageState(address: true, draftName: 'Maria'));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.tap(find.byType(VanepPrimaryButton));
      await tester.pump();

      verify(cubit.save).called(1);
      verifyNever(cubit.clearAddress);
    });
  });

  group('feedback', () {
    Future<void> emit(
      WidgetTester tester,
      PersonalDataFeedback feedback,
    ) async {
      final initial = pageState();
      whenListen(
        cubit,
        Stream.value(initial.copyWith(feedback: feedback)),
        initialState: initial,
      );
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the save success copy', (tester) async {
      useTallScreen(tester);
      await emit(tester, const PersonalDataSaveSuccessFeedback());

      expect(find.text('Dados pessoais salvos.'), findsOneWidget);
      verify(cubit.clearFeedback).called(1);
    });

    testWidgets('shows the cleared-house confirmation', (tester) async {
      useTallScreen(tester);
      await emit(tester, const PersonalDataAddressClearedFeedback());

      expect(find.text('Endereço removido.'), findsOneWidget);
    });

    testWidgets('shows the mapped error when clearing fails', (tester) async {
      useTallScreen(tester);
      await emit(
        tester,
        const PersonalDataAddressFailureFeedback(
          PersonalAddressFailure.network,
        ),
      );

      expect(
        find.text('Sem conexão com o servidor. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a save failure when the address page is not open', (
      tester,
    ) async {
      useTallScreen(tester);
      await emit(
        tester,
        const PersonalDataAddressSaveFailureFeedback(
          PersonalAddressFailure.validation,
        ),
      );

      expect(
        find.text('Revise os campos do endereço e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('leaves an address save failure to the address page on top', (
      tester,
    ) async {
      useTallScreen(tester);
      final initial = pageState();
      final controller = Stream<PersonalDataState>.multi((stream) {
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          stream.add(
            initial.copyWith(
              feedback: const PersonalDataAddressSaveFailureFeedback(
                PersonalAddressFailure.validation,
              ),
            ),
          );
        });
      });
      whenListen(cubit, controller, initialState: initial);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      Navigator.of(tester.element(find.byType(PersonalDataPage))).push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('página por cima')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(
        find.text('Revise os campos do endereço e tente novamente.'),
        findsNothing,
      );
    });

    testWidgets('shows the mapped profile failure', (tester) async {
      useTallScreen(tester);
      await emit(
        tester,
        const PersonalDataFailureFeedback(NetworkProfileEditFailure()),
      );

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows the field placeholders while loading', (tester) async {
      useTallScreen(tester);
      when(
        () => cubit.state,
      ).thenReturn(const PersonalDataState(status: PersonalDataStatus.loading));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(PersonalDataSkeleton), findsOneWidget);
      expect(
        find.byType(PersonalDataFieldSkeleton),
        findsNWidgets(personalDataFieldCount),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('the form has as many fields as the placeholder shows', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(
        find.byType(VanepFieldLabel),
        findsNWidgets(personalDataFieldCount),
      );
    });

    testWidgets('the placeholders keep the shape of the real form', (
      tester,
    ) async {
      useTallScreen(tester);
      when(
        () => cubit.state,
      ).thenReturn(const PersonalDataState(status: PersonalDataStatus.loading));

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();

      expect(find.byType(VanepPageHeader), findsOneWidget);
      expect(find.byType(VanepOutlinedPanel), findsOneWidget);
    });

    testWidgets('a load failure offers a retry', (tester) async {
      useTallScreen(tester);
      when(cubit.load).thenAnswer((_) async {});
      when(() => cubit.state).thenReturn(
        const PersonalDataState(status: PersonalDataStatus.loadFailed),
      );

      await tester.pumpWidget(personalDataHarness(cubit));
      await tester.pump();
      await tester.tap(find.byType(VanepPrimaryButton));

      verify(cubit.load).called(1);
    });
  });
}
