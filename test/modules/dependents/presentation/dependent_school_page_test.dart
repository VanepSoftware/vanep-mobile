import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_map_placeholder.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_page.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const davi = TestDependent(
  token: 'dep-davi',
  name: 'Davi Oliveira',
  school: TestDependentSchool(),
);

const classe10 = PlaceSuggestion(
  placeId: 'place-classe-10',
  primaryText: 'Escola Classe 10',
  secondaryText: 'Taguatinga Norte',
);

const classe08 = PlaceSuggestion(
  placeId: 'place-classe-08',
  primaryText: 'Escola Classe 08',
  secondaryText: 'Taguatinga Norte',
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
        result = await openDependentSchool(context, dependent: davi);
      }),
    );
  }

  VanepPrimaryButton saveButton(WidgetTester tester) {
    return tester.widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton));
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the current school selected and on the map', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('Escola'), findsOneWidget);
    expect(find.text('Davi'), findsOneWidget);
    expect(find.byType(VanepMapPlaceholder), findsOneWidget);
    expect(find.text('Colégio Delta'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('the current school shows its address under the name', (
    tester,
  ) async {
    const daviAtDelta = TestDependent(
      token: 'dep-davi',
      name: 'Davi Oliveira',
      school: TestDependentSchool(address: TestDependentAddress()),
    );
    await pumpAndOpen(
      tester,
      dependentsHarness(MockDependentsCubit(), (context) async {
        await openDependentSchool(context, dependent: daviAtDelta);
      }),
    );

    expect(
      find.text('QNL 5 Conjunto A, 12 · Taguatinga · Brasília/DF'),
      findsOneWidget,
    );
  });

  testWidgets('a search lists the schools with their region', (tester) async {
    doubles.searchAnswers(const Ok([classe10, classe08]));
    await openEditor(tester);

    await search(tester, 'Escola Classe');

    verify(() => doubles.autocomplete.search('Escola Classe', any())).called(1);
    expect(find.text('Escola Classe 10'), findsOneWidget);
    expect(find.text('Escola Classe 08'), findsOneWidget);
    expect(find.text('Taguatinga Norte'), findsNWidgets(2));
  });

  testWidgets('selecting a school names it on the map and enables saving', (
    tester,
  ) async {
    doubles.searchAnswers(const Ok([classe10, classe08]));
    await openEditor(tester);

    await search(tester, 'Escola Classe');
    await tester.tap(find.text('Escola Classe 08'));
    await tester.pumpAndSettle();

    expect(find.text('Escola Classe 08'), findsNWidgets(2));
    expect(find.text('Colégio Delta'), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('a failed search says it is unavailable and keeps the field', (
    tester,
  ) async {
    doubles.searchAnswers(const Err(PlaceAutocompleteFailure.network));
    await openEditor(tester);

    await search(tester, 'Escola Classe');

    expect(
      find.text(
        'A busca de escolas está indisponível. Tente de novo em instantes.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets('saving resolves the school and hands back the dependent', (
    tester,
  ) async {
    doubles
      ..searchAnswers(const Ok([classe10]))
      ..updateReturns(davi);
    when(
      () => doubles.resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Ok(School(token: 'school-classe-10', name: 'Escola Classe 10')),
    );
    when(doubles.session.completeAfterHandover).thenReturn(null);
    await openEditor(tester);

    await search(tester, 'Escola Classe');
    await tester.tap(find.text('Escola Classe 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => doubles.updateDependent(
                snapshot: davi,
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as DependentDraft;
    expect(draft.schoolToken, 'school-classe-10');
    expect(result, davi);
  });

  testWidgets('a place that is not a school shows the message of the back', (
    tester,
  ) async {
    doubles.searchAnswers(const Ok([classe10]));
    when(
      () => doubles.resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenAnswer(
      (_) async => const Err(
        SchoolRejectedFailure(detail: 'Este local não é uma escola.'),
      ),
    );
    await openEditor(tester);

    await search(tester, 'Escola Classe');
    await tester.tap(find.text('Escola Classe 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Este local não é uma escola.'), findsOneWidget);
    expect(find.byType(DependentSchoolPage), findsOneWidget);
  });
}
