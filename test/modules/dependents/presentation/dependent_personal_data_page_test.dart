import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_personal_data_page.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const pedro = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  birthDate: '2015-03-22',
  gender: Gender.male,
  document: '52998224725',
);

void main() {
  late DependentEditorDoubles doubles;
  Dependent? result;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    doubles = DependentEditorDoubles()..register();
    result = null;
  });

  tearDown(getIt.reset);

  Future<void> openEditor(WidgetTester tester) {
    return pumpAndOpen(
      tester,
      dependentsHarness(MockDependentsCubit(), (context) async {
        result = await openDependentPersonalData(context, dependent: pedro);
      }),
    );
  }

  VanepPrimaryButton saveButton(WidgetTester tester) {
    return tester.widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton));
  }

  testWidgets('shows the four fields filled with the dependent', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('Dados pessoais'), findsOneWidget);
    expect(find.text('Pedro'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Data de nascimento'), findsOneWidget);
    expect(find.byType(VanepGenderSelect), findsOneWidget);
    expect(find.text('CPF (opcional)'), findsOneWidget);
    expect(find.text('Pedro Oliveira'), findsOneWidget);
    expect(find.text('22/03/2015'), findsOneWidget);
    expect(find.text('529.982.247-25'), findsOneWidget);
  });

  testWidgets('saving is disabled while nothing changed', (tester) async {
    await openEditor(tester);

    expect(saveButton(tester).onPressed, isNull);

    await tester.enterText(fieldLabeled('Nome'), 'Pedro O. Lima');
    await tester.pump();

    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('the CPF and the birth date are masked while typed', (
    tester,
  ) async {
    await openEditor(tester);

    await tester.enterText(fieldLabeled('CPF (opcional)'), '39053344705');
    await tester.enterText(fieldLabeled('Data de nascimento'), '01022016');
    await tester.pump();

    expect(find.text('390.533.447-05'), findsOneWidget);
    expect(find.text('01/02/2016'), findsOneWidget);
  });

  testWidgets('an invalid CPF shows its message and sends nothing', (
    tester,
  ) async {
    await openEditor(tester);

    await tester.enterText(fieldLabeled('CPF (opcional)'), '11111111111');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(
      find.text('CPF inválido. Verifique os números informados.'),
      findsOneWidget,
    );
    verifyNever(
      () => doubles.updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    );
  });

  testWidgets('leaving a blank name shows the required message', (
    tester,
  ) async {
    await openEditor(tester);

    await tester.enterText(fieldLabeled('Nome'), '');
    await tester.tap(fieldLabeled('CPF (opcional)'));
    await tester.pump();

    expect(find.text('Informe o nome do dependente.'), findsOneWidget);
  });

  testWidgets('saving hands back the saved dependent', (tester) async {
    doubles.updateReturns(pedro);
    await openEditor(tester);

    await tester.enterText(fieldLabeled('Data de nascimento'), '01022016');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => doubles.updateDependent(
                snapshot: pedro,
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as DependentDraft;
    expect(draft.birthDate, '2016-02-01');
    expect(result, pedro);
    expect(find.byType(DependentPersonalDataPage), findsNothing);
  });
}
