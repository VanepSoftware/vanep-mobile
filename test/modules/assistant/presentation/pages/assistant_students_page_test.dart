import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_students_page.dart';

import '../../../auth/presentation/auth_test_harness.dart';
import '../../fixtures/assistant_fixtures.dart';

class MockAssistantStudentsCubit extends MockCubit<AssistantStudentsState>
    implements AssistantStudentsCubit {}

void main() {
  late MockAssistantStudentsCubit cubit;

  const readyState = AssistantStudentsState(
    status: AssistantStudentsStatus.ready,
    overview: testAssistantStudentsOverview,
  );

  setUp(() {
    cubit = MockAssistantStudentsCubit();
    when(() => cubit.loadStudents()).thenAnswer((_) async {});
    when(() => cubit.search(any())).thenReturn(null);
    when(() => cubit.selectRoster(any())).thenReturn(null);
  });

  Future<void> pumpPage(
    WidgetTester tester,
    AssistantStudentsState state,
  ) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      authTestApp(
        BlocProvider<AssistantStudentsCubit>.value(
          value: cubit,
          child: const AssistantStudentsPage(),
        ),
      ),
    );
  }

  testWidgets('shows the header with the selected van', (tester) async {
    await pumpPage(tester, readyState);

    expect(find.text('Alunos'), findsOneWidget);
    expect(find.text('Van de João · manhã · 3 alunos'), findsOneWidget);
  });

  testWidgets('shows one tab for each van', (tester) async {
    await pumpPage(tester, readyState);

    expect(find.text('João · manhã'), findsOneWidget);
    expect(find.text('Maria · tarde'), findsOneWidget);
  });

  testWidgets('selects the other van when its tab is tapped', (tester) async {
    await pumpPage(tester, readyState);

    await tester.tap(find.text('Maria · tarde'));

    verify(() => cubit.selectRoster(1)).called(1);
  });

  testWidgets('hides the tabs when there is a single van', (tester) async {
    await pumpPage(
      tester,
      AssistantStudentsState(
        status: AssistantStudentsStatus.ready,
        overview: AssistantStudentsOverview(
          rosters: [testAssistantStudentsOverview.rosters.first],
        ),
      ),
    );

    expect(find.text('Maria · tarde'), findsNothing);
  });

  testWidgets('lists the students alphabetically with their stop', (
    tester,
  ) async {
    await pumpPage(tester, readyState);

    expect(find.text('Ana Oliveira'), findsOneWidget);
    expect(find.text('Parada 3 · Col. Horizonte'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ana Oliveira')).dy,
      lessThan(tester.getTopLeft(find.text('Beatriz Santos')).dy),
    );
  });

  testWidgets('marks only the absent student as not going today', (
    tester,
  ) async {
    await pumpPage(tester, readyState);

    expect(find.text('Não vai hoje'), findsOneWidget);
  });

  testWidgets('sends what is typed to the cubit', (tester) async {
    await pumpPage(tester, readyState);

    await tester.enterText(find.byType(TextField), 'ana');

    verify(() => cubit.search('ana')).called(1);
  });

  testWidgets('tells when the search finds nobody', (tester) async {
    await pumpPage(tester, readyState.copyWith(query: 'zzz'));

    expect(find.text('Nenhum aluno encontrado.'), findsOneWidget);
  });

  testWidgets('shows the retry button when loading fails', (tester) async {
    await pumpPage(
      tester,
      const AssistantStudentsState(
        status: AssistantStudentsStatus.loadFailed,
        failure: AssistantFailure.network,
      ),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));

    verify(() => cubit.loadStudents()).called(1);
  });

  testWidgets('shows the empty message when there are no vans', (tester) async {
    await pumpPage(
      tester,
      const AssistantStudentsState(
        status: AssistantStudentsStatus.ready,
        overview: AssistantStudentsOverview(),
      ),
    );

    expect(find.text('Você ainda não tem vans vinculadas.'), findsOneWidget);
  });

  testWidgets('does nothing yet when a student is tapped', (tester) async {
    await pumpPage(tester, readyState);

    await tester.tap(find.text('Ana Oliveira'));

    expect(find.text('Alunos'), findsOneWidget);
  });
}
