import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';

import '../../../core/ui/localized_harness.dart';
import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../dependents_mocks.dart';

typedef PlaceSearchResult =
    Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>;

const String openLabel = 'abrir';

Widget dependentsHarness(
  DependentsCubit dependents,
  void Function(BuildContext context) open,
) {
  return localizedHarness(
    BlocProvider<DependentsCubit>.value(
      value: dependents,
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => open(context),
              child: const Text(openLabel),
            ),
          ),
        ),
      ),
    ),
  );
}

Finder fieldLabeled(String label) => find.descendant(
  of: find.widgetWithText(VanepTextField, label),
  matching: find.byType(TextField),
);

Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> pumpAndOpen(WidgetTester tester, Widget harness) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(harness);
  await tester.tap(find.text(openLabel));
  await tester.pumpAndSettle();
}

class DependentEditorDoubles {
  final MockCreateDependent createDependent = MockCreateDependent();
  final MockUpdateDependent updateDependent = MockUpdateDependent();
  final MockFindSchoolDays findSchoolDays = MockFindSchoolDays();
  final MockReplaceSchoolDays replaceSchoolDays = MockReplaceSchoolDays();
  final MockResolveSchool resolveSchool = MockResolveSchool();
  final MockPlaceAutocompleteController autocomplete =
      MockPlaceAutocompleteController();
  final MockPlaceSearchSession session = MockPlaceSearchSession();
  final MockLookupCep lookupCep = MockLookupCep();
  final MockListStates listStates = MockListStates();
  final MockListCities listCities = MockListCities();

  void register() {
    when(() => autocomplete.session).thenReturn(session);
    when(session.currentToken).thenReturn('sess-1');
    when(autocomplete.dispose).thenReturn(null);
    when(() => listStates()).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: const [fakeDfState])),
    );
    when(() => listCities(uf: any(named: 'uf'))).thenAnswer(
      (_) async => Ok(
        fakeIbgeLocationsPage<BrazilianCity>(items: [fakeBrazilianCity()]),
      ),
    );

    getIt
      ..registerFactoryParam<DependentDetailCubit, String, void>(
        (token, _) => DependentDetailCubit(
          dependentToken: token,
          findSchoolDays: findSchoolDays,
        ),
      )
      ..registerFactoryParam<DependentPersonalDataCubit, Dependent?, void>(
        (dependent, _) => DependentPersonalDataCubit(
          createDependent: createDependent,
          updateDependent: updateDependent,
          dependent: dependent,
        ),
      )
      ..registerFactoryParam<DependentSchoolCubit, Dependent, void>(
        (dependent, _) => DependentSchoolCubit(
          dependent: dependent,
          autocomplete: autocomplete,
          resolveSchool: resolveSchool,
          updateDependent: updateDependent,
        ),
      )
      ..registerFactoryParam<DependentSchoolDaysCubit, String, void>(
        (token, _) => DependentSchoolDaysCubit(
          dependentToken: token,
          findSchoolDays: findSchoolDays,
          replaceSchoolDays: replaceSchoolDays,
        ),
      )
      ..registerFactoryParam<DependentPickupCubit, Dependent, void>(
        (dependent, _) => DependentPickupCubit(
          dependent: dependent,
          updateDependent: updateDependent,
          lookupCep: lookupCep,
          listStates: listStates,
          listCities: listCities,
          cepLookupDebounce: Duration.zero,
        ),
      );
  }

  void schoolDaysReturn(SchoolWeek week) {
    when(() => findSchoolDays(any())).thenAnswer((_) async => Ok(week));
  }

  void searchAnswers(PlaceSearchResult result) {
    when(() => autocomplete.search(any(), any())).thenAnswer((invocation) {
      final onResult =
          invocation.positionalArguments[1] as void Function(PlaceSearchResult);
      onResult(result);
    });
  }

  void updateReturns(Dependent saved) {
    when(
      () => updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => Ok(saved));
  }
}

void registerDependentWidgetFallbacks() {
  registerDependentFallbackValues();
  registerFallbackValue((PlaceSearchResult _) {});
}
