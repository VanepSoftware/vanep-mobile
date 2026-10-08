import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependents_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_card.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

Widget harness(DependentsCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<DependentsCubit>.value(
      value: cubit,
      child: const DependentsPage(),
    ),
  );
}

void main() {
  late MockDependentsCubit cubit;

  setUp(() {
    cubit = MockDependentsCubit();
  });

  void seed(DependentsState state) {
    whenListen(
      cubit,
      const Stream<DependentsState>.empty(),
      initialState: state,
    );
  }

  testWidgets('shows the empty state when there is no dependent', (
    tester,
  ) async {
    seed(const DependentsState(status: DependentsStatus.ready));

    await tester.pumpWidget(harness(cubit));

    expect(
      find.text('Você ainda não cadastrou nenhum dependente.'),
      findsOneWidget,
    );
    expect(find.text('Adicionar dependente'), findsOneWidget);
  });

  testWidgets('lists one card per dependent', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(DependentCard), findsNWidgets(2));
    expect(find.text('Helena Souza'), findsOneWidget);
    expect(find.text('Miguel Souza'), findsOneWidget);
  });

  testWidgets('marks only the default dependent', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(DependentDefaultBadge), findsOneWidget);
    expect(find.text('Padrão'), findsOneWidget);
  });

  testWidgets('a dependent without a birth date shows no age', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testDependentWithoutBirthDate],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.textContaining('ano'), findsNothing);
  });

  testWidgets('a dependent with a birth date shows an age', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.text('Helena Souza'), findsOneWidget);
    expect(find.textContaining('ano'), findsOneWidget);
  });

  testWidgets('the first load shows card placeholders', (tester) async {
    seed(const DependentsState(status: DependentsStatus.loading));

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(DependentCardSkeleton), findsNWidgets(3));
    expect(find.byType(DependentCard), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the placeholders keep the shape of the real card', (
    tester,
  ) async {
    seed(const DependentsState(status: DependentsStatus.loading));

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(VanepPageHeader), findsOneWidget);
    expect(find.byType(VanepOutlinedPanel), findsNWidgets(3));
  });

  testWidgets('a loading refresh keeps the cards on screen', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.loading,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(DependentCard), findsNWidgets(2));
    expect(find.byType(DependentCardSkeleton), findsNothing);
  });

  testWidgets('a single dependent offers no default control', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.text('Definir como padrão'), findsNothing);
  });

  testWidgets('two dependents offer the default control on the other one', (
    tester,
  ) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.text('Definir como padrão'), findsOneWidget);
  });

  testWidgets('choosing the default asks the cubit', (tester) async {
    seed(
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    );
    when(() => cubit.chooseDefault(any())).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('Definir como padrão'));

    verify(() => cubit.chooseDefault('dep-miguel')).called(1);
  });

  testWidgets('a failed load shows the retry state, not the empty state', (
    tester,
  ) async {
    seed(
      const DependentsState(
        status: DependentsStatus.loadFailed,
        failure: DependentNetworkFailure(),
      ),
    );
    when(cubit.loadDependents).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit));

    expect(
      find.text('Não foi possível carregar seus dependentes.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(
      find.text('Você ainda não cadastrou nenhum dependente.'),
      findsNothing,
    );
  });

  testWidgets('retrying asks the cubit to load again', (tester) async {
    seed(const DependentsState(status: DependentsStatus.loadFailed));
    when(cubit.loadDependents).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('Tentar novamente'));

    verify(cubit.loadDependents).called(1);
  });

  group('identity', () {
    testWidgets('uses the new chrome and none of the old', (tester) async {
      seed(
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent],
        ),
      );

      await tester.pumpWidget(harness(cubit));

      expect(find.byType(VanepAppBar), findsOneWidget);
      expect(find.byType(VanepPageHeader), findsOneWidget);
    });

    testWidgets('each dependent sits in its own outlined panel', (
      tester,
    ) async {
      seed(
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
        ),
      );

      await tester.pumpWidget(harness(cubit));

      expect(
        find.descendant(
          of: find.byType(DependentCard),
          matching: find.byType(VanepOutlinedPanel),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('only the default dependent has a highlighted panel', (
      tester,
    ) async {
      seed(
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
        ),
      );

      await tester.pumpWidget(harness(cubit));

      final panels = tester
          .widgetList<VanepOutlinedPanel>(find.byType(VanepOutlinedPanel))
          .toList();
      expect(panels.where((panel) => panel.highlighted), hasLength(1));
      expect(panels, hasLength(2));
    });

    testWidgets('the add button lives in the bottom bar', (tester) async {
      seed(const DependentsState(status: DependentsStatus.ready));

      await tester.pumpWidget(harness(cubit));

      expect(
        find.descendant(
          of: find.byType(VanepBottomBar),
          matching: find.text('Adicionar dependente'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no add button while the first load runs', (tester) async {
      seed(const DependentsState(status: DependentsStatus.loading));

      await tester.pumpWidget(harness(cubit));

      expect(find.byType(VanepBottomBar), findsNothing);
      expect(find.text('Gerenciar dependentes'), findsOneWidget);
    });

    testWidgets('no add button after the load failed', (tester) async {
      seed(const DependentsState(status: DependentsStatus.loadFailed));

      await tester.pumpWidget(harness(cubit));

      expect(find.byType(VanepBottomBar), findsNothing);
      expect(find.text('Gerenciar dependentes'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
