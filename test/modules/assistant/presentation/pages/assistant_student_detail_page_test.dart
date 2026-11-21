import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_student_detail_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_student_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_student_detail_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_student_detail_page.dart';

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
    home: Scaffold(body: home),
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

DateTime fixedClock() => DateTime(2026, 10, 14, 6);

void main() {
  group('student detail (VAN-74)', () {
    test('the mock finds a student listed by the students tab', () async {
      final detail = await const MockedAssistantStudentDetailDataSource(
        clock: fixedClock,
      ).findStudentDetail('mock-student-beatriz');

      expect(detail.name, 'Beatriz Santos');
      expect(detail.siblings.single.name, 'Gabriel Santos');
    });

    test('the guardian stays hidden until contact is allowed', () {
      const guardian = AssistantStudentGuardian(
        name: 'Patrícia Santos',
        relationship: 'Mãe',
      );
      const hidden = AssistantStudentDetail(
        token: 'a',
        name: 'Beatriz',
        schoolName: 'Colégio',
        pickupAddress: 'QNL 5',
        guardian: guardian,
      );
      const allowed = AssistantStudentDetail(
        token: 'a',
        name: 'Beatriz',
        schoolName: 'Colégio',
        pickupAddress: 'QNL 5',
        guardian: guardian,
        canSeeGuardianContact: true,
      );
      const withoutFamily = AssistantStudentDetail(
        token: 'a',
        name: 'Beatriz',
        schoolName: 'Colégio',
        pickupAddress: 'QNL 5',
        guardian: guardian,
        canSeeGuardianContact: true,
        hasFamilyInApp: false,
      );

      expect(hidden.visibleGuardian, isNull);
      expect(allowed.visibleGuardian, guardian);
      expect(withoutFamily.visibleGuardian, isNull);
    });

    blocTest<AssistantStudentDetailCubit, AssistantStudentDetailState>(
      'loads the detail',
      build: () {
        final repository = MockAssistantStudentDetailRepository();
        when(() => repository.findStudentDetail('s'))
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return AssistantStudentDetailCubit(
          findStudentDetail: FindAssistantStudentDetail(repository),
        );
      },
      act: (cubit) => cubit.loadDetail('s'),
      expect: () => [
        const AssistantStudentDetailState(),
        const AssistantStudentDetailState(
          status: AssistantStudentDetailStatus.loadFailed,
          failure: AssistantFailure.network,
        ),
      ],
    );

    testWidgets('shows boarding, days, siblings and the driver note', (
      tester,
    ) async {
      useTallScreen(tester);
      final detail = await const MockedAssistantStudentDetailDataSource(
        clock: fixedClock,
      ).findStudentDetail('mock-student-beatriz');
      await tester.pumpWidget(
        localizedApp(
          AssistantStudentDetailBody(
            detail: detail,
            today: const AssistantStudentToday(
              status: BoardingStatus.pending,
              stopNumber: 5,
            ),
          ),
        ),
      );

      expect(find.text('Hoje · aguardando embarque'), findsOneWidget);
      expect(find.text('Parada 5'), findsOneWidget);
      expect(find.text('Janela 6h43–6h53'), findsOneWidget);
      expect(find.text('mesma parada'), findsOneWidget);
      expect(find.text('Dias e trechos'), findsOneWidget);
      expect(find.text('Gabriel Santos'), findsOneWidget);
      expect(find.text('Desembarque pelo portão lateral.'), findsOneWidget);
      expect(find.text('Responsável'), findsOneWidget);
      expect(find.text('Patrícia Santos'), findsOneWidget);
    });
  });
}
