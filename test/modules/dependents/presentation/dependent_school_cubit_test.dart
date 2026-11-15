import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_state.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

typedef PlaceSearchResult =
    Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>;

const pedro = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  school: TestDependentSchool(),
);

const pedroAtHorizonte = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  school: TestDependentSchool(
    token: 'school-horizonte',
    name: 'Colégio Horizonte',
  ),
);

const horizontePlace = PlaceSuggestion(
  placeId: 'place-horizonte',
  primaryText: 'Colégio Horizonte',
  secondaryText: 'Taguatinga, Brasília - DF',
);

const classePlace = PlaceSuggestion(
  placeId: 'place-classe',
  primaryText: 'Escola Classe 08',
  secondaryText: 'Ceilândia, Brasília - DF',
);

const horizonteSchool = School(
  token: 'school-horizonte',
  name: 'Colégio Horizonte',
);

void main() {
  late MockPlaceAutocompleteController autocomplete;
  late MockPlaceSearchSession session;
  late MockResolveSchool resolveSchool;
  late MockUpdateDependent updateDependent;

  setUpAll(() {
    registerDependentFallbackValues();
    registerFallbackValue((PlaceSearchResult _) {});
  });

  setUp(() {
    autocomplete = MockPlaceAutocompleteController();
    session = MockPlaceSearchSession();
    resolveSchool = MockResolveSchool();
    updateDependent = MockUpdateDependent();
    when(() => autocomplete.session).thenReturn(session);
    when(session.currentToken).thenReturn('sess-1');
  });

  DependentSchoolCubit buildCubit({Dependent dependent = pedro}) {
    return DependentSchoolCubit(
      dependent: dependent,
      autocomplete: autocomplete,
      resolveSchool: resolveSchool,
      updateDependent: updateDependent,
    );
  }

  void searchAnswers(PlaceSearchResult result) {
    when(() => autocomplete.search(any(), any())).thenAnswer((invocation) {
      final onResult =
          invocation.positionalArguments[1] as void Function(PlaceSearchResult);
      onResult(result);
    });
  }

  void resolveReturns(Result<SchoolFailure, School> result) {
    when(
      () => resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenAnswer((_) async => result);
  }

  void updateReturns(Result<DependentFailure, Dependent>? result) {
    when(
      () => updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('opens with the current school selected and nothing to save', () {
    final cubit = buildCubit();

    expect(cubit.state.isCurrentSchoolSelected, isTrue);
    expect(cubit.state.selectedName, 'Colégio Delta');
    expect(cubit.state.canSave, isFalse);
  });

  test('a dependent without school opens with nothing selected', () {
    final cubit = buildCubit(
      dependent: const TestDependent(token: 'dep-ana', name: 'Ana'),
    );

    expect(cubit.state.isCurrentSchoolSelected, isFalse);
    expect(cubit.state.selectedName, isNull);
    expect(cubit.state.canSave, isFalse);
  });

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'a search replaces the suggestions',
    setUp: () => searchAnswers(const Ok([horizontePlace, classePlace])),
    build: buildCubit,
    act: (cubit) => cubit.search('Colégio'),
    verify: (cubit) {
      expect(cubit.state.suggestions, [horizontePlace, classePlace]);
      verify(() => autocomplete.search('Colégio', any())).called(1);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'a failed search shows the failure and keeps the selection',
    setUp: () => searchAnswers(const Err(PlaceAutocompleteFailure.network)),
    build: buildCubit,
    act: (cubit) => cubit
      ..selectSuggestion(classePlace)
      ..search('Escola'),
    verify: (cubit) {
      expect(cubit.state.searchFailure, PlaceAutocompleteFailure.network);
      expect(cubit.state.suggestions, isEmpty);
      expect(cubit.state.selectedPlace, classePlace);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'selecting a suggestion marks it, names the map and enables saving',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectSuggestion(horizontePlace)
      ..selectSuggestion(classePlace),
    verify: (cubit) {
      expect(cubit.state.selectedPlace, classePlace);
      expect(cubit.state.isCurrentSchoolSelected, isFalse);
      expect(cubit.state.selectedName, 'Escola Classe 08');
      expect(cubit.state.canSave, isTrue);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'saving resolves the place, then updates the school token',
    setUp: () {
      resolveReturns(const Ok(horizonteSchool));
      updateReturns(const Ok(pedroAtHorizonte));
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.selectSuggestion(horizontePlace);
      await cubit.save();
    },
    verify: (cubit) {
      verify(
        () => resolveSchool(placeId: 'place-horizonte', sessionToken: 'sess-1'),
      ).called(1);
      final draft =
          verify(
                () => updateDependent(
                  snapshot: pedro,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.schoolToken, 'school-horizonte');
      expect(cubit.state.status, DependentEditorStatus.saved);
      expect(cubit.state.saved, pedroAtHorizonte);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'the Places session ends after a successful resolve',
    setUp: () {
      resolveReturns(const Ok(horizonteSchool));
      updateReturns(const Ok(pedroAtHorizonte));
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.selectSuggestion(horizontePlace);
      await cubit.save();
    },
    verify: (_) {
      verify(session.completeAfterHandover).called(1);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'a rejected place keeps the selection and the detail of the back',
    setUp: () => resolveReturns(
      const Err(SchoolRejectedFailure(detail: 'Este local não é uma escola.')),
    ),
    build: buildCubit,
    act: (cubit) async {
      cubit.selectSuggestion(classePlace);
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentEditorStatus.editing);
      expect(cubit.state.selectedPlace, classePlace);
      expect(
        cubit.state.resolveFailure,
        const SchoolRejectedFailure(detail: 'Este local não é uma escola.'),
      );
      verifyNever(session.completeAfterHandover);
      verifyNever(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      );
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'a failed update keeps the selection and shows the failure',
    setUp: () {
      resolveReturns(const Ok(horizonteSchool));
      updateReturns(const Err(DependentNetworkFailure()));
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.selectSuggestion(horizontePlace);
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentEditorStatus.editing);
      expect(cubit.state.selectedPlace, horizontePlace);
      expect(cubit.state.updateFailure, const DependentNetworkFailure());
      expect(cubit.state.canSave, isTrue);
    },
  );

  blocTest<DependentSchoolCubit, DependentSchoolState>(
    'a place that resolves to the current school closes without a change',
    setUp: () {
      resolveReturns(
        const Ok(School(token: 'school-delta', name: 'Colégio Delta')),
      );
      updateReturns(null);
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.selectSuggestion(horizontePlace);
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentEditorStatus.saved);
      expect(cubit.state.saved, pedro);
    },
  );

  test('closing the editor disposes the search', () async {
    when(autocomplete.dispose).thenReturn(null);

    await buildCubit().close();

    verify(autocomplete.dispose).called(1);
  });
}
