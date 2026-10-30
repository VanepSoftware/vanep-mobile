import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_state.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockFindAssistantStudents findAssistantStudents;

  const readyState = AssistantStudentsState(
    status: AssistantStudentsStatus.ready,
    overview: testAssistantStudentsOverview,
  );

  setUp(() {
    findAssistantStudents = MockFindAssistantStudents();
  });

  AssistantStudentsCubit buildCubit() {
    return AssistantStudentsCubit(findAssistantStudents: findAssistantStudents);
  }

  blocTest<AssistantStudentsCubit, AssistantStudentsState>(
    'loads the overview',
    build: () {
      when(
        () => findAssistantStudents(),
      ).thenAnswer((_) async => const Ok(testAssistantStudentsOverview));
      return buildCubit();
    },
    act: (cubit) => cubit.loadStudents(),
    expect: () => [const AssistantStudentsState(), readyState],
  );

  blocTest<AssistantStudentsCubit, AssistantStudentsState>(
    'fails and keeps the failure',
    build: () {
      when(
        () => findAssistantStudents(),
      ).thenAnswer((_) async => const Err(AssistantFailure.network));
      return buildCubit();
    },
    act: (cubit) => cubit.loadStudents(),
    expect: () => [
      const AssistantStudentsState(),
      const AssistantStudentsState(
        status: AssistantStudentsStatus.loadFailed,
        failure: AssistantFailure.network,
      ),
    ],
  );

  blocTest<AssistantStudentsCubit, AssistantStudentsState>(
    'keeps the query while searching',
    build: buildCubit,
    seed: () => readyState,
    act: (cubit) => cubit.search('ana'),
    expect: () => [readyState.copyWith(query: 'ana')],
  );

  blocTest<AssistantStudentsCubit, AssistantStudentsState>(
    'clears the query when another van is selected',
    build: buildCubit,
    seed: () => readyState.copyWith(query: 'ana'),
    act: (cubit) => cubit.selectRoster(1),
    expect: () => [readyState.copyWith(selectedRosterIndex: 1, query: '')],
  );

  test('lists the students of the selected van filtered by the query', () {
    final state = readyState.copyWith(query: 'santos');

    expect(state.visibleStudents, [testAssistantStudentBeatriz]);
  });

  test('has no visible students before loading', () {
    expect(const AssistantStudentsState().visibleStudents, isEmpty);
  });
}
