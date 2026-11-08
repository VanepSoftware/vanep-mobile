import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_state.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/pages/van_students_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

class MockVanStudentsCubit extends MockCubit<VanStudentsState>
    implements VanStudentsCubit {}

final loadedState = VanStudentsState(
  status: VanStudentsStatus.loaded,
  students: vanStudents,
  occupancy: studentsOccupancy,
);

void main() {
  late MockVanStudentsCubit cubit;
  late MockTextSharer sharer;
  String? addedStudent;

  setUp(() {
    cubit = MockVanStudentsCubit();
    sharer = MockTextSharer();
    addedStudent = null;
    when(() => sharer.shareText(any())).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.inviteFamily(any())).thenAnswer((_) async {});
    when(() => cubit.mergeFamily(any())).thenAnswer((_) async {});
    when(() => cubit.dismissFamilyMatch(any())).thenAnswer((_) async {});
    when(() => cubit.shareParentsGroupLink()).thenAnswer((_) async {});
  });

  setUpAll(() => registerFallbackValue(uninvitedLaura));

  Future<void> pumpPage(WidgetTester tester, VanStudentsState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<VanStudentsCubit>.value(
          value: cubit,
          child: VanStudentsPage(
            vanCaption: 'Sprinter · SDF4E21',
            sharer: sharer,
            clock: () => DateTime(2026, 11, 8, 10),
            onAddStudent: () async => addedStudent,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the van, the progress, the match and the rows', (
    tester,
  ) async {
    await pumpPage(tester, loadedState);

    expect(find.text('Alunos'), findsWidgets);
    expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
    expect(find.text('24 de 28 com família no app'), findsOneWidget);
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('É o mesmo Rafael?'), findsOneWidget);
    expect(
      find.textContaining('A família Costa cadastrou Rafael Costa, 9 anos.'),
      findsOneWidget,
    );
    expect(find.text('Col. Horizonte · manhã · ida e volta'), findsOneWidget);
    expect(find.text('Convite enviado há 2 dias'), findsOneWidget);
    expect(find.text('Família entrou · confirmar'), findsOneWidget);
    expect(find.text('Convidar'), findsNWidgets(2));
    expect(find.text('Reenviar'), findsOneWidget);
  });

  testWidgets('tapping invite calls the cubit with the student', (
    tester,
  ) async {
    await pumpPage(tester, loadedState);

    await tester.ensureVisible(find.text('Convidar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convidar').first);

    verify(() => cubit.inviteFamily(uninvitedLaura)).called(1);
  });

  testWidgets('"Não é" dismisses and "Sim, juntar" asks before merging', (
    tester,
  ) async {
    await pumpPage(tester, loadedState);

    await tester.tap(find.text('Não é'));
    verify(() => cubit.dismissFamilyMatch(joinedRafael)).called(1);

    await tester.tap(find.text('Sim, juntar'));
    await tester.pumpAndSettle();
    expect(find.text('Juntar com Rafael Costa?'), findsOneWidget);
    await tester.tap(find.text('Juntar'));
    await tester.pumpAndSettle();

    verify(() => cubit.mergeFamily(joinedRafael)).called(1);
  });

  testWidgets('a share request opens the share sheet with the invite text', (
    tester,
  ) async {
    whenListen(
      cubit,
      Stream.fromIterable([
        loadedState.copyWith(
          shareRequest: const VanStudentsShareRequest(
            inviteUrl: 'https://vanep.com.br/convite/X',
            studentName: 'Laura Mendes',
          ),
        ),
      ]),
      initialState: loadedState,
    );
    when(() => cubit.clearShareRequest()).thenReturn(null);
    await pumpPage(tester, loadedState);
    await tester.pump();

    verify(
      () => sharer.shareText(
        'Oi! Sou o motorista da van de Laura Mendes. Baixe o Vanep para '
        'receber os avisos do transporte: https://vanep.com.br/convite/X',
      ),
    ).called(1);
    verify(() => cubit.clearShareRequest()).called(1);
  });

  testWidgets('the filters show the counts', (tester) async {
    await pumpPage(tester, loadedState);

    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Com família'), findsOneWidget);
    expect(find.text('Sem família'), findsOneWidget);
    expect(find.text('Manhã'), findsOneWidget);
    expect(find.text('Tarde'), findsOneWidget);

    await tester.tap(find.text('Sem família'));
    verify(() => cubit.selectFamilyFilter(StudentFamilyFilter.withoutFamily))
        .called(1);
  });

  testWidgets('an empty van shows the empty message without progress', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const VanStudentsState(status: VanStudentsStatus.loaded),
    );

    expect(find.text('Nenhum aluno por aqui ainda.'), findsOneWidget);
    expect(find.text('0 de 0 com família no app'), findsNothing);
    expect(find.text('Mandar link no grupo de pais'), findsNothing);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpPage(
      tester,
      const VanStudentsState(status: VanStudentsStatus.loadFailed),
    );

    expect(find.text('Não foi possível carregar os alunos.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('adding a student refreshes the list and confirms it', (
    tester,
  ) async {
    addedStudent = 'Laura Mendes';
    await pumpPage(tester, loadedState);

    await tester.tap(find.text('Adicionar aluno'));
    await tester.pump();

    verify(() => cubit.refresh()).called(1);
    expect(find.text('Laura Mendes foi cadastrado.'), findsOneWidget);
  });
  testWidgets('search replaces the header title, not the body', (tester) async {
    await pumpPage(tester, loadedState.copyWith(isSearching: true));
    expect(find.text('Alunos'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(TextField),
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'rafa');
    verify(() => cubit.changeQuery('rafa')).called(1);
    await tester.tap(find.byIcon(Icons.close));
    verify(() => cubit.closeSearch()).called(1);
  });
}
