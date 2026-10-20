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
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_today_route_page.dart';

class MockAssistantChecklistCubit extends MockCubit<AssistantChecklistState>
    implements AssistantChecklistCubit {}

const tPendingStudent = AssistantChecklistItem(
  studentToken: 'stu-1',
  studentName: 'Ana Clara',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-1',
  stopAddress: 'Av. Paulista, 500',
  status: BoardingStatus.pending,
);

const tBoardedStudent = AssistantChecklistItem(
  studentToken: 'stu-2',
  studentName: 'Bruno Lima',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-1',
  stopAddress: 'Av. Paulista, 500',
  status: BoardingStatus.boarded,
  confirmedBy: ConfirmationSource.assistant,
);

const tSchoolStop = AssistantTripStop(
  id: 'stop-1',
  order: 1,
  title: 'Colégio São Bento',
  address: 'Av. Paulista, 500',
  isSchool: true,
  items: [tPendingStudent, tBoardedStudent],
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
        child: const AssistantTodayRoutePage(),
      ),
    ),
  );
}

void main() {
  late MockAssistantChecklistCubit cubit;

  setUpAll(() {
    registerFallbackValue(NoShowReason.notifiedByGuardian);
  });

  setUp(() {
    cubit = MockAssistantChecklistCubit();
  });

  testWidgets('shows empty route message when stops is empty', (tester) async {
    whenListen(
      cubit,
      const Stream<AssistantChecklistState>.empty(),
      initialState: const AssistantChecklistState(),
    );

    await tester.pumpWidget(buildHarness(cubit));

    expect(
      find.text('Nenhuma parada programada para esta rota hoje.'),
      findsOneWidget,
    );
  });

  testWidgets('shows revoked link state when isLinkRevoked is true', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<AssistantChecklistState>.empty(),
      initialState: const AssistantChecklistState(isLinkRevoked: true),
    );

    await tester.pumpWidget(buildHarness(cubit));

    expect(find.text('Acesso revogado'), findsOneWidget);
    expect(
      find.text('O motorista removeu seu vínculo com esta van.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'displays stops, progress, confirmation attribution, and triggers boarding & bulk drop-off',
    (tester) async {
      whenListen(
        cubit,
        const Stream<AssistantChecklistState>.empty(),
        initialState: const AssistantChecklistState(
          vanToken: 'van-1',
          stops: [tSchoolStop],
          selectedStudentTokens: {'stu-2'},
        ),
      );
      when(() => cubit.confirmBoarding(any())).thenAnswer((_) async {});
      when(() => cubit.confirmBulkDropOff()).thenAnswer((_) async {});
      when(() => cubit.selectAllAtStop(any())).thenReturn(null);

      await tester.pumpWidget(buildHarness(cubit));

      expect(find.text('1 de 2 alunos atendidos'), findsOneWidget);
      expect(find.text('Ana Clara'), findsOneWidget);
      expect(find.text('Bruno Lima'), findsOneWidget);
      expect(find.text('Confirmado por assistente'), findsOneWidget);
      expect(find.text('Dar baixa em lote (1)'), findsOneWidget);

      final boardingButton = find.widgetWithText(
        ElevatedButton,
        'Confirmar embarque',
      );
      final buttonSize = tester.getSize(boardingButton);
      expect(buttonSize.height, greaterThanOrEqualTo(44));

      await tester.tap(boardingButton);
      await tester.pump();
      verify(() => cubit.confirmBoarding('stu-1')).called(1);

      await tester.tap(find.text('Dar baixa em lote (1)'));
      await tester.pump();
      verify(() => cubit.confirmBulkDropOff()).called(1);
    },
  );

  testWidgets('opens no-show modal and confirms reason', (tester) async {
    whenListen(
      cubit,
      const Stream<AssistantChecklistState>.empty(),
      initialState: const AssistantChecklistState(
        vanToken: 'van-1',
        stops: [tSchoolStop],
      ),
    );
    when(() => cubit.markNoShow(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(buildHarness(cubit));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Não compareceu'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar ausência'), findsOneWidget);
    expect(find.text('Não estava no local'), findsOneWidget);

    await tester.tap(find.text('Não estava no local'));
    await tester.pump();

    await tester.tap(find.text('Confirmar ausência'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.markNoShow('stu-1', NoShowReason.notAtLocation),
    ).called(1);
  });
}
