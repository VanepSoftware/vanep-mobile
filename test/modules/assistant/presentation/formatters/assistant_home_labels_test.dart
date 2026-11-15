import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_en.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';

void main() {
  final pt = AppLocalizationsPt();
  final en = AppLocalizationsEn();

  group('joinFirstNames', () {
    test('one name stays as it is', () {
      expect(joinFirstNames(pt, ['Rafael Costa']), 'Rafael');
    });

    test('two names are joined by "e"', () {
      expect(joinFirstNames(pt, ['Helena Reis', 'Davi Reis']), 'Helena e Davi');
    });

    test('three names use commas and "e"', () {
      expect(
        joinFirstNames(pt, ['Júlia Barros', 'Enzo Barros', 'Lívia Barros']),
        'Júlia, Enzo e Lívia',
      );
    });

    test('english joins with "and"', () {
      expect(joinFirstNames(en, ['Miguel', 'Laís']), 'Miguel and Laís');
    });
  });

  test('clock times follow the language', () {
    final time = DateTime(2026, 10, 14, 6, 20);

    expect(formatClockTime(time, languageCode: 'pt'), '6h20');
    expect(formatClockTime(time, languageCode: 'en'), '6:20');
  });

  test('dates show day and month', () {
    expect(formatDayAndMonth(DateTime(2026, 10, 2)), '02/10');
  });

  group('stopPassengersLine', () {
    test('lists who boards and leaves out who is absent', () {
      final stop = testRouteOnPickup().stops[3];

      expect(stopPassengersLine(pt, stop), 'Miguel');
    });

    test('school stops read as a drop-off', () {
      final stop = testRouteAtSchool().stops[2];

      expect(stopPassengersLine(pt, stop), 'Desembarque · Helena e Davi');
    });
  });

  group('stopRouteLine', () {
    test('names who boarded and explains who did not', () {
      final stop = testRouteOnPickup().stops[1];

      expect(stopRouteLine(pt, stop), 'Theo · Laura não estava no ponto');
    });

    test('names who is not going today', () {
      final stop = testRouteOnPickup().stops[3];

      expect(stopRouteLine(pt, stop), 'Miguel · Ana não vai hoje');
    });

    test('a school with many students shows the count', () {
      final stop = testRouteOnPickup().stops[4];

      expect(stopRouteLine(pt, stop), 'Desembarque · 5 alunos');
    });

    test('a school with up to two students names them', () {
      final stop = testRouteOnPickup().stops[5];

      expect(stopRouteLine(pt, stop), 'Desembarque · Miguel');
    });
  });

  test('stop kinds have a title each', () {
    expect(stopKindTitle(pt, RouteStopKind.pickupHome), 'Embarque em casa');
    expect(stopKindTitle(pt, RouteStopKind.dropOffSchool), 'Chegada na escola');
  });

  test('the van label uses the driver first name', () {
    expect(
      assistantHomeVanLabel(pt, testAssistantVanPrimary),
      'João · Mercedes Sprinter 2024 ABC-1234',
    );
  });

  group('absenceNoticeLine', () {
    final now = DateTime(2026, 10, 14, 7);

    test('today, says who notified and when', () {
      expect(
        absenceNoticeLine(
          pt,
          testRouteAbsenceAna,
          now: now,
          languageCode: 'pt',
        ),
        'Avisado pela família · 6h02',
      );
    });

    test('on an earlier day, says it was yesterday', () {
      final earlier = AssistantAbsence(
        passengerToken: 'passenger-lucas',
        passengerName: 'Lucas',
        date: DateTime(2026, 10, 14),
        kind: AbsenceKind.notGoing,
        source: AbsenceSource.client,
        notifiedAt: DateTime(2026, 10, 13, 20),
      );

      expect(
        absenceNoticeLine(pt, earlier, now: now, languageCode: 'pt'),
        'Avisado ontem',
      );
    });
  });
}
