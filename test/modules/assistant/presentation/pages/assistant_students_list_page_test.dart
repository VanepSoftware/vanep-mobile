import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_students_list_page.dart';

class MockAssistantChecklistCubit extends MockCubit<AssistantChecklistState>
    implements AssistantChecklistCubit {}

const tStop = AssistantTripStop(
  id: 'stop-1',
  order: 1,
  title: 'Parada 1',
  address: 'Rua A, 10',
  isSchool: false,
  items: [
    AssistantChecklistItem(
      studentToken: 'stu-1',
      studentName: 'Ana Clara',
      schoolName: 'Colégio Objetivo',
      stopId: 'stop-1',
      stopAddress: 'Rua A, 10',
      status: BoardingStatus.pending,
    ),
    AssistantChecklistItem(
      studentToken: 'stu-2',
      studentName: 'Lucas Mendes',
      schoolName: 'Colégio Bandeirantes',
      stopId: 'stop-1',
      stopAddress: 'Rua A, 10',
      status: BoardingStatus.droppedOff,
    ),
  ],
);

Widget buildHarness(AssistantChecklistCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(
      body: BlocProvider<AssistantChecklistCubit>.value(
        value: cubit,
        child: const AssistantStudentsListPage(),
      ),
    ),
  );
}

void main() {
  late MockAssistantChecklistCubit cubit;

  setUp(() {
    cubit = MockAssistantChecklistCubit();
  });

  testWidgets('renders students list and delegates search and filter actions', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<AssistantChecklistState>.empty(),
      initialState: const AssistantChecklistState(stops: [tStop]),
    );
    when(() => cubit.updateSearchQuery(any())).thenReturn(null);
    when(() => cubit.updateStatusFilter(any())).thenReturn(null);

    await tester.pumpWidget(buildHarness(cubit));

    expect(find.text('Ana Clara'), findsOneWidget);
    expect(find.text('Lucas Mendes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Lucas');
    verify(() => cubit.updateSearchQuery('Lucas')).called(1);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Entregue'));
    verify(
      () => cubit.updateStatusFilter(BoardingStatus.droppedOff),
    ).called(1);
  });

  testWidgets('shows empty state when filtered list is empty', (tester) async {
    whenListen(
      cubit,
      const Stream<AssistantChecklistState>.empty(),
      initialState: const AssistantChecklistState(
        stops: [tStop],
        searchQuery: 'Inexistente',
      ),
    );

    await tester.pumpWidget(buildHarness(cubit));

    expect(find.text('Nenhum aluno encontrado.'), findsOneWidget);
  });
}
