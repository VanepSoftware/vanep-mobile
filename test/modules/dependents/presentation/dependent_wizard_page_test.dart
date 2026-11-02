import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_wizard_page.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const pedro = TestDependent(token: 'dep-pedro', name: 'Pedro Oliveira');

const pedroMissingSchool = ContractReadiness(
  ready: false,
  gaps: [
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: 'dep-pedro',
      field: ContractReadinessField.school,
    ),
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: 'dep-pedro',
      field: ContractReadinessField.schoolDays,
    ),
  ],
);

void main() {
  late DependentEditorDoubles doubles;
  late MockFindContractReadiness findContractReadiness;
  late DependentsCubit dependents;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    doubles = DependentEditorDoubles()..register();
    doubles.schoolDaysReturn(const SchoolWeek.empty());
    findContractReadiness = MockFindContractReadiness();
    when(() => findContractReadiness(any())).thenAnswer(
      (_) async => const Ok<ContractReadinessFailure, ContractReadiness>(
        pedroMissingSchool,
      ),
    );
    dependents = DependentsCubit(
      findMyDependents: MockFindMyDependents(),
      setDefaultDependent: MockSetDefaultDependent(),
      deleteDependent: MockRemoveDependent(),
      findContractReadiness: findContractReadiness,
    );
  });

  tearDown(() async {
    await dependents.close();
    await getIt.reset();
  });

  void createReturns(Result<DependentFailure, Dependent> result) {
    when(() => doubles.createDependent(any())).thenAnswer((_) async => result);
  }

  Future<void> openCreation(WidgetTester tester) {
    return pumpAndOpen(
      tester,
      dependentsHarness(dependents, openDependentCreationWizard),
    );
  }

  Future<void> createPedro(WidgetTester tester) async {
    await tester.enterText(fieldLabeled('Nome'), 'Pedro Oliveira');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
  }

  Future<void> skip(WidgetTester tester) async {
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
  }

  group('creating', () {
    testWidgets('starts on personal data without skipping', (tester) async {
      await openCreation(tester);

      expect(find.text('Dados pessoais'), findsOneWidget);
      expect(find.text('Passo 1 de 4'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Pular'), findsNothing);
    });

    testWidgets('skipping every optional step ends on the new detail', (
      tester,
    ) async {
      createReturns(const Ok(pedro));
      await openCreation(tester);

      await createPedro(tester);
      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Passo 2 de 4'), findsOneWidget);
      await skip(tester);
      expect(find.text('Passo 3 de 4'), findsOneWidget);
      await skip(tester);
      expect(find.text('Embarque'), findsOneWidget);
      expect(find.text('Passo 4 de 4'), findsOneWidget);
      expect(find.text('Concluir'), findsOneWidget);
      await skip(tester);

      expect(find.byType(DependentDetailView), findsOneWidget);
      expect(find.text('Pedro Oliveira'), findsOneWidget);
      expect(find.text('Completar cadastro'), findsOneWidget);
      expect(dependents.state.dependents, [pedro]);

      await tapBack(tester);

      expect(find.text(openLabel), findsOneWidget);
    });

    testWidgets('a failed creation stays on personal data', (tester) async {
      createReturns(const Err(DependentNetworkFailure()));
      await openCreation(tester);

      await createPedro(tester);

      expect(find.text('Passo 1 de 4'), findsOneWidget);
      expect(find.text('Pedro Oliveira'), findsOneWidget);
      expect(
        find.text('Sem conexão com o servidor. Tente novamente.'),
        findsOneWidget,
      );
      expect(dependents.state.dependents, isEmpty);
    });

    testWidgets('going back from the first step creates nothing', (
      tester,
    ) async {
      await openCreation(tester);

      await tapBack(tester);

      expect(find.text(openLabel), findsOneWidget);
      verifyNever(() => doubles.createDependent(any()));
      verifyNever(() => findContractReadiness(any()));
    });

    testWidgets('going back after the creation opens the new detail', (
      tester,
    ) async {
      createReturns(const Ok(pedro));
      await openCreation(tester);
      await createPedro(tester);

      await tapBack(tester);

      expect(find.byType(DependentDetailView), findsOneWidget);
      expect(find.text('Passo 2 de 4'), findsNothing);

      await tapBack(tester);

      expect(find.text(openLabel), findsOneWidget);
      expect(dependents.state.dependents, [pedro]);
    });
  });

  group('completing', () {
    Future<void> openDetailOfPedro(WidgetTester tester) async {
      dependents.addDependent(pedro);
      await dependents.refreshReadiness();
      await pumpAndOpen(
        tester,
        dependentsHarness(
          dependents,
          (context) => openDependentDetail(context, 'dep-pedro'),
        ),
      );
    }

    testWidgets('only the missing steps, then back to the detail', (
      tester,
    ) async {
      await openDetailOfPedro(tester);

      await tester.tap(find.text('Completar cadastro'));
      await tester.pumpAndSettle();
      expect(find.text('Escola'), findsOneWidget);
      expect(find.text('Passo 1 de 2'), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);
      await skip(tester);
      expect(find.text('Dias e turnos'), findsOneWidget);
      expect(find.text('Passo 2 de 2'), findsOneWidget);
      expect(find.text('Concluir'), findsOneWidget);
      await skip(tester);

      expect(find.byType(DependentDetailView), findsOneWidget);
      verify(() => findContractReadiness(['dep-pedro'])).called(2);
    });

    testWidgets('going back from a step returns to the detail', (tester) async {
      await openDetailOfPedro(tester);
      await tester.tap(find.text('Completar cadastro'));
      await tester.pumpAndSettle();

      await tapBack(tester);

      expect(find.byType(DependentDetailView), findsOneWidget);
      expect(find.text('Passo 1 de 2'), findsNothing);
    });
  });
}
