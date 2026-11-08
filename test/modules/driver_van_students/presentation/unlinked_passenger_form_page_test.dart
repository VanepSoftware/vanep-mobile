import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_search_session.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_state.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/pages/unlinked_passenger_form_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

class MockUnlinkedPassengerFormCubit
    extends MockCubit<UnlinkedPassengerFormState>
    implements UnlinkedPassengerFormCubit {}

void main() {
  late MockUnlinkedPassengerFormCubit cubit;
  late MockPlaceAutocompleteController autocomplete;

  setUp(() {
    cubit = MockUnlinkedPassengerFormCubit();
    autocomplete = MockPlaceAutocompleteController();
    when(() => autocomplete.session).thenReturn(PlaceSearchSession());
    when(() => cubit.autocomplete).thenReturn(autocomplete);
    when(() => cubit.submit()).thenAnswer((_) async {});
  });

  Future<void> pumpForm(
    WidgetTester tester,
    UnlinkedPassengerFormState state,
  ) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<UnlinkedPassengerFormCubit>.value(
          value: cubit,
          child: const UnlinkedPassengerFormPage(
            vanCaption: 'Sprinter · SDF4E21',
          ),
        ),
      ),
    );
  }

  testWidgets('shows every section and submits', (tester) async {
    await pumpForm(
      tester,
      const UnlinkedPassengerFormState(draft: UnlinkedPassengerDraft()),
    );

    expect(find.text('Adicionar aluno'), findsOneWidget);
    expect(find.text('Escola'), findsOneWidget);
    expect(find.text('Embarque'), findsOneWidget);
    expect(find.text('Dias e trechos'), findsOneWidget);
    expect(find.text('Horário de embarque'), findsNothing);

    await tester.tap(find.text('Cadastrar aluno'));

    verify(() => cubit.submit()).called(1);
  });

  testWidgets('shows the errors once the driver tried to submit', (
    tester,
  ) async {
    await pumpForm(
      tester,
      const UnlinkedPassengerFormState(
        draft: UnlinkedPassengerDraft(),
        showErrors: true,
      ),
    );

    expect(find.text('Informe o nome do aluno.'), findsOneWidget);
    expect(find.text('Escolha a escola.'), findsOneWidget);
    expect(find.text('Escolha o turno escolar.'), findsOneWidget);
    expect(find.text('Marque pelo menos um trecho.'), findsOneWidget);
  });

  testWidgets('selected legs show the pickup times', (tester) async {
    await pumpForm(tester, UnlinkedPassengerFormState(draft: completeDraft()));

    expect(find.text('Horário de embarque'), findsOneWidget);
    expect(find.text('06:40'), findsOneWidget);
    expect(find.text('12:10'), findsOneWidget);
    expect(find.text('Col. Horizonte'), findsOneWidget);
  });

  testWidgets('a saved student closes the page with its name', (tester) async {
    String? popped;
    when(() => cubit.state)
        .thenReturn(UnlinkedPassengerFormState(draft: completeDraft()));
    whenListen(
      cubit,
      Stream.fromIterable([
        UnlinkedPassengerFormState(
          draft: completeDraft(),
          status: UnlinkedPassengerFormStatus.saved,
        ),
      ]),
      initialState: UnlinkedPassengerFormState(draft: completeDraft()),
    );
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) =>
                      BlocProvider<UnlinkedPassengerFormCubit>.value(
                        value: cubit,
                        child: const UnlinkedPassengerFormPage(
                          vanCaption: 'Van',
                        ),
                      ),
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(popped, 'Laura Mendes');
  });
  testWidgets(
    'school search displays suggestions and hands selection to the cubit',
    (tester) async {
      when(() => autocomplete.search(any(), any())).thenAnswer((invocation) {
        final onResult =
            invocation.positionalArguments[1]
                as void Function(
                  Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>,
                );
        onResult(const Ok([schoolSearchSuggestion]));
      });
      when(() => autocomplete.handOverSelection()).thenReturn('search-session');
      when(() => cubit.selectSchool(schoolSearchSuggestion, 'search-session'))
          .thenAnswer((_) async {});
      await pumpForm(
        tester,
        const UnlinkedPassengerFormState(draft: UnlinkedPassengerDraft()),
      );
      final search = find.descendant(
        of: find.byType(VanepPlaceAutocompleteField),
        matching: find.byType(TextField),
      );
      await tester.enterText(search, 'Horizonte');
      await tester.pump();
      expect(find.text('Col. Horizonte'), findsOneWidget);
      await tester.tap(find.text('Col. Horizonte'));
      await tester.pump();
      verify(() => autocomplete.search('Horizonte', any())).called(1);
      verify(() => cubit.selectSchool(schoolSearchSuggestion, 'search-session'))
          .called(1);
    },
  );
}
