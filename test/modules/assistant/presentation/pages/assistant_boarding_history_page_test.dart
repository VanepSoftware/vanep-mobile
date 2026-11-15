import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_student_detail_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_boarding_history_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_history_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_boarding_history_page.dart';

import '../../mocks/assistant_mocks.dart';

Widget localizedApp(Widget body) {
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
    home: Scaffold(body: body),
  );
}

final now = DateTime(2026, 10, 14, 7);
DateTime fixedClock() => now;

void main() {
  final pt = AppLocalizationsPt();

  group('boarding history (VAN-74)', () {
    test('keeps the last 30 days, latest first', () {
      final days = latestHistoryFirst([
        AssistantBoardingHistoryDay(date: DateTime(2026, 9, 1)),
        AssistantBoardingHistoryDay(date: DateTime(2026, 10, 10)),
        AssistantBoardingHistoryDay(date: DateTime(2026, 10, 13)),
      ], now: now);

      expect(days.map((day) => day.date.day), [13, 10]);
    });

    test(
      'the mock only has school days, with a no-show and an absence',
      () async {
        final days = await const MockedAssistantStudentDetailDataSource(
          clock: fixedClock,
        ).findBoardingHistory('mock-student-beatriz');

        expect(
          days.every((day) => day.date.weekday <= DateTime.friday),
          isTrue,
        );
        expect(
          days.any((day) => day.outbound?.status == BoardingStatus.noShow),
          isTrue,
        );
        expect(
          days.any(
            (day) => day.outbound?.status == BoardingStatus.notGoingToday,
          ),
          isTrue,
        );
      },
    );

    test('each leg reads as one line', () {
      final day = DateTime(2026, 10, 13);
      String line(AssistantLegRecord? record) =>
          legRecordLine(pt, record, languageCode: 'pt');

      expect(
        line(
          AssistantLegRecord(
            status: BoardingStatus.droppedOff,
            boardedAt: day.add(const Duration(hours: 6, minutes: 48)),
            droppedOffAt: day.add(const Duration(hours: 7, minutes: 15)),
          ),
        ),
        'Embarcou 6h48 · desceu 7h15',
      );
      expect(
        line(
          const AssistantLegRecord(
            status: BoardingStatus.noShow,
            noShowReason: NoShowReason.notAtStop,
          ),
        ),
        'Não embarcou · não estava no ponto',
      );
      expect(
        line(
          const AssistantLegRecord(
            status: BoardingStatus.noShow,
            noShowReason: NoShowReason.other,
            skipNotes: 'foi ao médico',
          ),
        ),
        'Não embarcou · foi ao médico',
      );
      expect(
        line(const AssistantLegRecord(status: BoardingStatus.notGoingToday)),
        'Não foi',
      );
      expect(line(null), 'Sem registro');
    });

    blocTest<AssistantBoardingHistoryCubit, AssistantBoardingHistoryState>(
      'loads the history, latest first',
      build: () {
        final repository = MockAssistantStudentDetailRepository();
        when(() => repository.findBoardingHistory('s')).thenAnswer(
          (_) async => Ok([
            AssistantBoardingHistoryDay(date: DateTime(2026, 10, 9)),
            AssistantBoardingHistoryDay(date: DateTime(2026, 10, 13)),
          ]),
        );
        return AssistantBoardingHistoryCubit(
          findBoardingHistory: FindAssistantBoardingHistory(repository),
          clock: fixedClock,
        );
      },
      act: (cubit) => cubit.loadHistory('s'),
      verify: (cubit) =>
          expect(cubit.state.days.map((day) => day.date.day), [13, 9]),
    );

    testWidgets('the page shows each day with its legs', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          AssistantBoardingHistoryBody(
            studentName: 'Beatriz Santos',
            days: [
              AssistantBoardingHistoryDay(
                date: DateTime(2026, 10, 13),
                outbound: const AssistantLegRecord(
                  status: BoardingStatus.notGoingToday,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Histórico de embarques'), findsNothing);
      expect(find.text('Últimos 30 dias'), findsOneWidget);
      expect(find.text('Terça, 13/10'), findsOneWidget);
      expect(find.text('Não foi'), findsOneWidget);
      expect(find.text('Sem registro'), findsOneWidget);
    });
  });
}
