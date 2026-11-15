import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_absences_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_absences_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_student_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_van_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_absences.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_students_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_home_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_today_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/mark_present_in_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/undo_stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_students_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_students.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';

class MockAssistantRepository extends Mock implements AssistantRepository {}

class MockValidateAssistantInvite extends Mock
    implements ValidateAssistantInvite {}

class MockRegisterAssistantWithInvite extends Mock
    implements RegisterAssistantWithInvite {}

class MockGetLinkedVans extends Mock implements GetLinkedVans {}

class MockAssistantVansRepository extends Mock
    implements AssistantVansRepository {}

class MockAssistantVansDataSource extends Mock
    implements AssistantVansDataSource {}

class MockFindAssistantVans extends Mock implements FindAssistantVans {}

class MockAssistantStudentsRepository extends Mock
    implements AssistantStudentsRepository {}

class MockAssistantStudentsDataSource extends Mock
    implements AssistantStudentsDataSource {}

class MockFindAssistantStudents extends Mock
    implements FindAssistantStudents {}

class MockAssistantRouteRepository extends Mock
    implements AssistantRouteRepository {}

class MockAssistantRouteDataSource extends Mock
    implements AssistantRouteDataSource {}

class MockFindAssistantHomeOverview extends Mock
    implements FindAssistantHomeOverview {}

class MockFindAssistantTodayRoute extends Mock
    implements FindAssistantTodayRoute {}

class MockConfirmStopPassengers extends Mock implements ConfirmStopPassengers {}

class MockUndoStopConfirmation extends Mock implements UndoStopConfirmation {}

class MockMarkPresentInVan extends Mock implements MarkPresentInVan {}

class MockAssistantHomeCubit extends MockCubit<AssistantHomeState>
    implements AssistantHomeCubit {}

class MockAssistantAbsencesRepository extends Mock
    implements AssistantAbsencesRepository {}

class MockAssistantAbsencesDataSource extends Mock
    implements AssistantAbsencesDataSource {}

class MockFindAssistantAbsences extends Mock implements FindAssistantAbsences {}

class MockAssistantVanDetailRepository extends Mock
    implements AssistantVanDetailRepository {}

class MockAssistantStudentDetailRepository extends Mock
    implements AssistantStudentDetailRepository {}

class MockRespondToAssistantInvite extends Mock
    implements RespondToAssistantInvite {}

class MockAssistantVansCubit extends MockCubit<AssistantVansState>
    implements AssistantVansCubit {}

class MockAssistantStudentsCubit extends MockCubit<AssistantStudentsState>
    implements AssistantStudentsCubit {}

void registerFakeAssistantTabs(GetIt getIt) {
  final home = MockAssistantHomeCubit();
  whenListen(
    home,
    const Stream<AssistantHomeState>.empty(),
    initialState: const AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: AssistantHomeOverview(),
    ),
  );
  when(() => home.load(selectedVanToken: any(named: 'selectedVanToken')))
      .thenAnswer((_) async {});
  when(() => home.load()).thenAnswer((_) async {});
  final vans = MockAssistantVansCubit();
  whenListen(
    vans,
    const Stream<AssistantVansState>.empty(),
    initialState: const AssistantVansState(
      status: AssistantVansStatus.ready,
      overview: AssistantVansOverview(),
    ),
  );
  when(() => vans.loadVans()).thenAnswer((_) async {});
  final students = MockAssistantStudentsCubit();
  whenListen(
    students,
    const Stream<AssistantStudentsState>.empty(),
    initialState: const AssistantStudentsState(
      status: AssistantStudentsStatus.ready,
      overview: AssistantStudentsOverview(),
    ),
  );
  when(() => students.loadStudents()).thenAnswer((_) async {});
  getIt
    ..registerFactory<AssistantHomeCubit>(() => home)
    ..registerFactory<AssistantVansCubit>(() => vans)
    ..registerFactory<AssistantStudentsCubit>(() => students);
}
