import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependents_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependents_list_card.dart';

import '../../../core/ui/localized_harness.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const pedroAtDelta = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  birthDate: '2015-03-22',
  gender: Gender.male,
  school: TestDependentSchool(),
);

Widget listHarness(DependentsCubit cubit) {
  return localizedHarness(
    BlocProvider<DependentsCubit>.value(
      value: cubit,
      child: const DependentsPage(),
    ),
  );
}

void main() {
  late MockDependentsCubit cubit;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    cubit = MockDependentsCubit();
    when(cubit.loadDependents).thenAnswer((_) async {});
  });

  tearDown(getIt.reset);

  void seed(DependentsState state) {
    whenListen(
      cubit,
      const Stream<DependentsState>.empty(),
      initialState: state,
    );
  }

  testWidgets('the default dependent is marked in the row title', (
    tester,
  ) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(listHarness(cubit));

    expect(find.byType(DependentListRow), findsNWidgets(2));
    expect(find.text('Helena · Padrão'), findsOneWidget);
    expect(find.text('Miguel'), findsOneWidget);
  });

  testWidgets('the subtitle shows the age and the school', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [pedroAtDelta, testDependentWithoutBirthDate],
      ),
    );

    await tester.pumpWidget(listHarness(cubit));

    expect(
      find.textContaining(RegExp(r'^\d+ anos · Colégio Delta$')),
      findsOneWidget,
    );
    expect(find.textContaining('ano'), findsOneWidget);
  });

  testWidgets('an incomplete dependent shows the flag instead of the subtitle', (
    tester,
  ) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
        readinessByToken: {
          'dep-helena': {ContractReadinessField.school},
          'dep-miguel': {},
        },
      ),
    );

    await tester.pumpWidget(listHarness(cubit));

    expect(find.text('Cadastro incompleto'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d+ anos$')), findsOneWidget);
  });

  testWidgets('an unavailable readiness shows no incomplete row', (
    tester,
  ) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent],
      ),
    );

    await tester.pumpWidget(listHarness(cubit));

    expect(find.text('Cadastro incompleto'), findsNothing);
  });

  testWidgets('no dependent shows the empty state with the add button', (
    tester,
  ) async {
    seed(const DependentsState(status: DependentsStatus.ready));

    await tester.pumpWidget(listHarness(cubit));

    expect(
      find.textContaining('Dependentes são as pessoas que viajam na van'),
      findsOneWidget,
    );
    expect(find.text('Adicionar dependente'), findsOneWidget);
    expect(find.byType(DependentListRow), findsNothing);
  });

  testWidgets('the first load shows skeleton rows', (tester) async {
    seed(const DependentsState(status: DependentsStatus.loading));

    await tester.pumpWidget(listHarness(cubit));

    expect(find.byType(DependentListRowSkeleton), findsNWidgets(3));
    expect(find.byType(DependentListRow), findsNothing);
  });

  testWidgets('a failed load can be retried', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.loadFailed,
        failure: DependentNetworkFailure(),
      ),
    );

    await tester.pumpWidget(listHarness(cubit));
    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Não foi possível carregar seus dependentes.'),
      findsOneWidget,
    );
    verify(cubit.loadDependents).called(1);
  });

  testWidgets('a failed default change shows its message', (tester) async {
    whenListen(
      cubit,
      Stream.value(
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
          failure: DependentNetworkFailure(),
        ),
      ),
      initialState: const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(listHarness(cubit));
    await tester.pump();

    expect(
      find.text('Sem conexão com o servidor. Tente novamente.'),
      findsOneWidget,
    );
  });

  group('navigation', () {
    late DependentEditorDoubles doubles;

    setUp(() {
      doubles = DependentEditorDoubles()..register();
      doubles.schoolDaysReturn(const SchoolWeek.empty());
      seed(
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
        ),
      );
    });

    testWidgets('tapping a row opens its detail', (tester) async {
      await tester.pumpWidget(listHarness(cubit));

      await tester.tap(find.text('Miguel'));
      await tester.pumpAndSettle();

      expect(find.byType(DependentDetailView), findsOneWidget);
      expect(find.text('Miguel Souza'), findsOneWidget);
    });

    testWidgets('the header add button opens the creation wizard', (
      tester,
    ) async {
      await tester.pumpWidget(listHarness(cubit));

      await tester.tap(find.byTooltip('Adicionar dependente'));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 4'), findsOneWidget);
    });

    testWidgets('the add button under the list opens the creation wizard', (
      tester,
    ) async {
      await tester.pumpWidget(listHarness(cubit));

      await tester.tap(find.text('Adicionar dependente'));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 4'), findsOneWidget);
      expect(find.text('Dados pessoais'), findsOneWidget);
    });
  });
}
