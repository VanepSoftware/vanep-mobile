import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_school_days_page.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';
import 'dependents_page_harness.dart';

const davi = TestDependent(token: 'dep-davi', name: 'Davi Oliveira');

final weekdaysAfternoon = SchoolWeek.fromDays([
  for (final day in [
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  ])
    SchoolDay(weekday: day, shift: SchoolShift.afternoon),
]);

void main() {
  late DependentEditorDoubles doubles;
  SchoolWeek? result;

  setUpAll(registerDependentWidgetFallbacks);

  setUp(() {
    doubles = DependentEditorDoubles()..register();
    doubles.schoolDaysReturn(weekdaysAfternoon);
    result = null;
  });

  tearDown(getIt.reset);

  Future<void> openEditor(WidgetTester tester) {
    return pumpAndOpen(
      tester,
      dependentsHarness(MockDependentsCubit(), (context) async {
        result = await openDependentSchoolDays(context, dependent: davi);
      }),
    );
  }

  VanepPrimaryButton saveButton(WidgetTester tester) {
    return tester.widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton));
  }

  testWidgets('shows seven days from Monday with the counter', (tester) async {
    await openEditor(tester);

    expect(find.text('Dias e turnos'), findsOneWidget);
    expect(find.text('Davi'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('5 dias'), findsOneWidget);
    final days = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    final tops = [for (final day in days) tester.getTopLeft(find.text(day)).dy];
    expect(tops, [...tops]..sort());
    expect(find.text('Tarde'), findsNWidgets(5));
    expect(find.text('Sem aula'), findsNWidgets(2));
  });

  testWidgets('a dependent without days starts from Monday to Friday', (
    tester,
  ) async {
    doubles.schoolDaysReturn(const SchoolWeek.empty());
    await openEditor(tester);

    expect(find.text('5 dias'), findsOneWidget);
    expect(find.text('Manhã'), findsNWidgets(5));
    expect(find.text('Sem aula'), findsNWidgets(2));
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('each switch reads out the day', (tester) async {
    final semantics = tester.ensureSemantics();
    await openEditor(tester);

    expect(find.bySemanticsLabel('Segunda: tem aula'), findsOneWidget);
    expect(find.bySemanticsLabel('Domingo: tem aula'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the shift picker offers the four shifts', (tester) async {
    await openEditor(tester);

    await tester.tap(find.byTooltip('Turno de Segunda: Tarde'));
    await tester.pumpAndSettle();

    expect(find.text('Manhã'), findsOneWidget);
    expect(find.text('Noite'), findsOneWidget);
    expect(find.text('Integral'), findsOneWidget);
    expect(find.text('Tarde'), findsWidgets);

    await tester.tap(find.text('Integral'));
    await tester.pumpAndSettle();

    expect(find.text('Integral'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('saving is disabled while the week is unchanged', (tester) async {
    await openEditor(tester);

    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(find.bySemanticsLabel('Sábado: tem aula'));
    await tester.pumpAndSettle();

    expect(find.text('6 dias'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('saving hands back the saved week', (tester) async {
    when(
      () => doubles.replaceSchoolDays(
        dependentToken: any(named: 'dependentToken'),
        week: any(named: 'week'),
      ),
    ).thenAnswer((invocation) async {
      return Ok(invocation.namedArguments[#week] as SchoolWeek);
    });
    await openEditor(tester);

    await tester.tap(find.bySemanticsLabel('Sábado: tem aula'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(result, weekdaysAfternoon.turnOn(Weekday.saturday));
    expect(find.byType(DependentSchoolDaysPage), findsNothing);
  });

  testWidgets('a failed load offers to try again', (tester) async {
    final results = <Result<DependentFailure, SchoolWeek>>[
      const Err(DependentNetworkFailure()),
      Ok(weekdaysAfternoon),
    ];
    when(() => doubles.findSchoolDays(any()))
        .thenAnswer((_) async => results.removeAt(0));
    await openEditor(tester);

    expect(
      find.text('Não foi possível carregar os dias e turnos.'),
      findsOneWidget,
    );
    expect(find.text('Segunda'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Segunda'), findsOneWidget);
  });
}
