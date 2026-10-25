import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_personal_data_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_pickup_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_days_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_readiness_card.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_school_week_bar.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const pedro = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  birthDate: '2015-03-22',
  gender: Gender.male,
  school: TestDependentSchool(),
  address: TestDependentAddress(),
);

const davi = TestDependent(token: 'dep-davi', name: 'Davi Oliveira');

final weekdaysWithFullTimeThursday = SchoolWeek.fromDays([
  for (final day in [
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.friday,
  ])
    SchoolDay(weekday: day, shift: SchoolShift.morning),
  const SchoolDay(weekday: Weekday.thursday, shift: SchoolShift.fullTime),
]);

void main() {
  late MockDependentsCubit dependents;
  late DependentEditorDoubles doubles;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    dependents = MockDependentsCubit();
    doubles = DependentEditorDoubles()..register();
    doubles.schoolDaysReturn(weekdaysWithFullTimeThursday);
    when(() => dependents.refreshReadiness()).thenAnswer((_) async {});
  });

  tearDown(getIt.reset);

  void seed(DependentsState state) {
    whenListen(
      dependents,
      const Stream<DependentsState>.empty(),
      initialState: state,
    );
  }

  DependentsState readyWith(
    List<TestDependent> list, {
    Map<String, Set<ContractReadinessField>>? readiness,
  }) {
    return DependentsState(
      status: DependentsStatus.ready,
      dependents: list,
      readinessByToken: readiness,
    );
  }

  Future<void> openDetail(WidgetTester tester, String token) {
    return pumpAndOpen(
      tester,
      dependentsHarness(
        dependents,
        (context) => openDependentDetail(context, token),
      ),
    );
  }

  group('structure', () {
    testWidgets('the header shows the name, the age and the default mark', (
      tester,
    ) async {
      seed(readyWith([testHelenaDependent, pedro]));

      await openDetail(tester, 'dep-helena');

      expect(find.text('Helena'), findsOneWidget);
      expect(find.text('Dependente'), findsOneWidget);
      expect(find.text('Helena Souza'), findsOneWidget);
      expect(find.textContaining('dependente padrão'), findsOneWidget);
    });

    testWidgets('the readiness card shows only while something is missing', (
      tester,
    ) async {
      seed(
        readyWith(
          [pedro],
          readiness: {
            'dep-pedro': {
              ContractReadinessField.school,
              ContractReadinessField.schoolDays,
            },
          },
        ),
      );

      await openDetail(tester, 'dep-pedro');

      expect(find.byType(DependentReadinessCard), findsOneWidget);
      expect(find.text('2 de 4'), findsOneWidget);
      expect(find.text('Completar cadastro'), findsOneWidget);
    });

    testWidgets('a ready dependent has no readiness card', (tester) async {
      seed(readyWith([pedro], readiness: {'dep-pedro': {}}));

      await openDetail(tester, 'dep-pedro');

      expect(find.byType(DependentReadinessCard), findsNothing);
    });

    testWidgets('an unavailable readiness shows no card', (tester) async {
      seed(readyWith([davi]));

      await openDetail(tester, 'dep-davi');

      expect(find.byType(DependentReadinessCard), findsNothing);
    });

    testWidgets('a complete dependent has no missing marks', (tester) async {
      seed(readyWith([pedro]));

      await openDetail(tester, 'dep-pedro');

      expect(find.text('Não informado'), findsNothing);
      expect(find.byType(DependentSchoolWeekBar), findsOneWidget);
    });

    testWidgets('the school row shows only the name of the school', (
      tester,
    ) async {
      const pedroAtDelta = TestDependent(
        token: 'dep-pedro',
        name: 'Pedro Oliveira',
        school: TestDependentSchool(address: TestDependentAddress()),
      );
      seed(readyWith([pedroAtDelta]));

      await openDetail(tester, 'dep-pedro');

      expect(find.text('Colégio Delta'), findsOneWidget);
      expect(find.textContaining('Brasília/DF'), findsNothing);
    });

    testWidgets('the pickup row shows the address in short', (tester) async {
      seed(readyWith([pedro]));

      await openDetail(tester, 'dep-pedro');

      expect(find.text('QNL 5 Conjunto A, 12 · Taguatinga'), findsOneWidget);
    });

    testWidgets('every missing item reads as not informed', (tester) async {
      doubles.schoolDaysReturn(const SchoolWeek.empty());
      seed(readyWith([davi]));

      await openDetail(tester, 'dep-davi');

      expect(find.text('Não informado'), findsNWidgets(4));
      expect(find.byType(DependentSchoolWeekBar), findsNothing);
    });
  });

  group('days and shifts row', () {
    testWidgets('shows the week bar and reads out the number of days', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      seed(readyWith([pedro]));

      await openDetail(tester, 'dep-pedro');

      expect(find.byType(DependentSchoolWeekBar), findsOneWidget);
      expect(find.bySemanticsLabel('Dias e turnos, 5 dias'), findsOneWidget);
      expect(find.text('Seg a sex'), findsNothing);
      semantics.dispose();
    });

    testWidgets('shows a skeleton while the week loads', (tester) async {
      final pending = Completer<Result<DependentFailure, SchoolWeek>>();
      when(() => doubles.findSchoolDays(any()))
          .thenAnswer((_) => pending.future);
      seed(readyWith([pedro]));

      await tester.pumpWidget(
        dependentsHarness(
          dependents,
          (context) => openDependentDetail(context, 'dep-pedro'),
        ),
      );
      await tester.tap(find.text(openLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DependentSchoolWeekBarSkeleton), findsOneWidget);
      pending.complete(const Ok(SchoolWeek.empty()));
      await tester.pumpAndSettle();
    });

    testWidgets('a failed load offers to try again', (tester) async {
      final results = <Result<DependentFailure, SchoolWeek>>[
        const Err(DependentNetworkFailure()),
        Ok(weekdaysWithFullTimeThursday),
      ];
      when(() => doubles.findSchoolDays(any()))
          .thenAnswer((_) async => results.removeAt(0));
      seed(readyWith([pedro]));

      await openDetail(tester, 'dep-pedro');
      expect(find.byType(DependentSchoolWeekBar), findsNothing);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentSchoolWeekBar), findsOneWidget);
    });
  });

  testWidgets('the van and contract rows do nothing', (tester) async {
    seed(readyWith([pedro]));
    await openDetail(tester, 'dep-pedro');

    await tester.tap(find.text('Van'));
    await tester.tap(find.text('Contrato'));
    await tester.pumpAndSettle();

    expect(find.byType(DependentDetailView), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  group('default dependent menu', () {
    testWidgets('offers to set as default for another dependent', (
      tester,
    ) async {
      when(() => dependents.chooseDefault(any())).thenAnswer((_) async {});
      seed(readyWith([testHelenaDependent, pedro]));
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.byTooltip('Mais opções'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Definir como padrão'));
      await tester.pumpAndSettle();

      verify(() => dependents.chooseDefault('dep-pedro')).called(1);
    });

    testWidgets('is not offered for the default dependent', (tester) async {
      seed(readyWith([testHelenaDependent, pedro]));
      await openDetail(tester, 'dep-helena');

      expect(find.byTooltip('Mais opções'), findsNothing);
    });

    testWidgets('is not offered with a single dependent', (tester) async {
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      expect(find.byTooltip('Mais opções'), findsNothing);
    });
  });

  group('removal', () {
    Future<void> confirmRemoval(WidgetTester tester) async {
      await tester.tap(find.text('Remover dependente'));
      await tester.pumpAndSettle();
      expect(find.text('Remover Pedro?'), findsOneWidget);
      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();
    }

    testWidgets('a confirmed removal goes back to the list', (tester) async {
      when(() => dependents.removeDependent(any()))
          .thenAnswer((_) async => null);
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await confirmRemoval(tester);

      verify(() => dependents.removeDependent('dep-pedro')).called(1);
      expect(find.byType(DependentDetailView), findsNothing);
      expect(find.text('Pedro foi removido da lista.'), findsOneWidget);
    });

    testWidgets('the detail keeps its content while closing', (tester) async {
      final states = StreamController<DependentsState>();
      addTearDown(states.close);
      whenListen(dependents, states.stream, initialState: readyWith([pedro]));
      when(() => dependents.removeDependent(any())).thenAnswer((_) async {
        states.add(readyWith([]));
        await Future<void>.delayed(Duration.zero);
        return null;
      });
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.text('Remover dependente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pedro Oliveira'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(DependentDetailView), findsNothing);
    });

    testWidgets('a failed removal stays with the message of the back', (
      tester,
    ) async {
      when(() => dependents.removeDependent(any())).thenAnswer(
        (_) async => const DependentRejectedFailure(
          detail: 'O dependente está num pedido de orçamento aberto.',
        ),
      );
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await confirmRemoval(tester);

      expect(find.byType(DependentDetailView), findsOneWidget);
      expect(
        find.text('O dependente está num pedido de orçamento aberto.'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling changes nothing', (tester) async {
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.text('Remover dependente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => dependents.removeDependent(any()));
      expect(find.byType(DependentDetailView), findsOneWidget);
    });
  });

  group('editors', () {
    testWidgets('the school row saves the new school into the list', (
      tester,
    ) async {
      const pedroAtHorizonte = TestDependent(
        token: 'dep-pedro',
        name: 'Pedro Oliveira',
        school: TestDependentSchool(
          token: 'school-horizonte',
          name: 'Colégio Horizonte',
        ),
      );
      doubles
        ..searchAnswers(
          const Ok([
            PlaceSuggestion(
              placeId: 'place-horizonte',
              primaryText: 'Colégio Horizonte',
              secondaryText: 'Taguatinga',
            ),
          ]),
        )
        ..updateReturns(pedroAtHorizonte);
      when(
        () => doubles.resolveSchool(
          placeId: any(named: 'placeId'),
          sessionToken: any(named: 'sessionToken'),
        ),
      ).thenAnswer(
        (_) async => const Ok(
          School(token: 'school-horizonte', name: 'Colégio Horizonte'),
        ),
      );
      when(() => doubles.session.completeAfterHandover()).thenReturn(null);
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.text('Escola'));
      await tester.pumpAndSettle();
      expect(find.byType(DependentSchoolPage), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Colégio');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Colégio Horizonte'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentSchoolPage), findsNothing);
      verify(() => dependents.replaceDependent(pedroAtHorizonte)).called(1);
      verify(() => dependents.refreshReadiness()).called(1);
    });

    testWidgets('the days row puts the saved week on the bar', (tester) async {
      doubles.schoolDaysReturn(const SchoolWeek.empty());
      final saved = const SchoolWeek.empty().turnOn(Weekday.monday);
      when(
        () => doubles.replaceSchoolDays(
          dependentToken: any(named: 'dependentToken'),
          week: any(named: 'week'),
        ),
      ).thenAnswer((_) async => Ok(saved));
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');
      expect(find.byType(DependentSchoolWeekBar), findsNothing);

      await tester.tap(find.text('Dias e turnos'));
      await tester.pumpAndSettle();
      expect(find.byType(DependentSchoolDaysPage), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Segunda: tem aula'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentSchoolDaysPage), findsNothing);
      expect(find.byType(DependentSchoolWeekBar), findsOneWidget);
      verify(() => dependents.refreshReadiness()).called(1);
    });

    testWidgets('the pickup row saves the new address into the list', (
      tester,
    ) async {
      doubles.updateReturns(pedro);
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.text('Embarque'));
      await tester.pumpAndSettle();
      expect(find.byType(DependentPickupPage), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '12'), '340');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentPickupPage), findsNothing);
      final draft =
          verify(
                () => doubles.updateDependent(
                  snapshot: pedro,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.address.number, '340');
      verify(() => dependents.replaceDependent(pedro)).called(1);
    });

    testWidgets('the personal data row saves the new name into the list', (
      tester,
    ) async {
      doubles.updateReturns(pedro);
      seed(readyWith([pedro]));
      await openDetail(tester, 'dep-pedro');

      await tester.tap(find.text('Dados pessoais'));
      await tester.pumpAndSettle();
      expect(find.byType(DependentPersonalDataPage), findsOneWidget);
      await tester.enterText(fieldLabeled('Nome'), 'Pedro O. Lima');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentPersonalDataPage), findsNothing);
      verify(() => dependents.replaceDependent(pedro)).called(1);
      verify(() => dependents.refreshReadiness()).called(1);
    });
  });
}
