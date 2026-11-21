import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_absences_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_absences.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absences_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_absences_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_absences_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_absences_page.dart';

import '../../fixtures/assistant_absences_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

Widget localizedApp(Widget home) {
  return MaterialApp(
    theme: VanepTheme.light(),
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final now = DateTime(2026, 10, 14, 7);

void main() {
  group('absences and changes (VAN-72)', () {
    blocTest<AssistantAbsencesCubit, AssistantAbsencesState>(
      'groups what the repository returns',
      build: () {
        final find = MockFindAssistantAbsences();
        when(() => find('van'))
            .thenAnswer((_) async => Ok(testAbsencesOfTheWeek(now)));
        return AssistantAbsencesCubit(
          findAssistantAbsences: find,
          clock: () => now,
        );
      },
      act: (cubit) => cubit.loadAbsences('van'),
      expect: () => [
        const AssistantAbsencesState(),
        AssistantAbsencesState(
          status: AssistantAbsencesStatus.ready,
          overview: groupAssistantAbsences(
            testAbsencesOfTheWeek(now),
            now: now,
          ),
        ),
      ],
    );

    blocTest<AssistantAbsencesCubit, AssistantAbsencesState>(
      'keeps the failure',
      build: () {
        final find = MockFindAssistantAbsences();
        when(() => find('van'))
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return AssistantAbsencesCubit(findAssistantAbsences: find);
      },
      act: (cubit) => cubit.loadAbsences('van'),
      expect: () => [
        const AssistantAbsencesState(),
        const AssistantAbsencesState(
          status: AssistantAbsencesStatus.loadFailed,
          failure: AssistantFailure.network,
        ),
      ],
    );

    test('the mocked data source matches the frame', () async {
      final absences = await MockedAssistantAbsencesDataSource(clock: () => now)
          .findAbsences('van');
      final overview = groupAssistantAbsences(absences, now: now);

      expect(overview.today, hasLength(3));
      expect(overview.upcoming.last.passengerNames, [
        'Helena Reis',
        'Davi Reis',
      ]);
    });

    testWidgets('an empty day says nobody is missing', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(
            body: AssistantAbsencesBody(overview: AssistantAbsencesOverview()),
          ),
        ),
      );

      expect(find.text('Ninguém falta hoje.'), findsOneWidget);
      expect(find.text('Próximos dias'), findsNothing);
    });

    testWidgets('shows today, the next days and the kinds', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: AssistantAbsencesBody(
              overview: groupAssistantAbsences(
                testAbsencesOfTheWeek(now),
                now: now,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('Próximos dias'), findsOneWidget);
      expect(find.text('Na volta: casa da avó, QNL 7'), findsOneWidget);
      expect(find.text('Helena e Davi'), findsOneWidget);
      expect(find.text('Só ida'), findsOneWidget);
      expect(find.text('Não vai'), findsNWidgets(3));
    });
  });
}
