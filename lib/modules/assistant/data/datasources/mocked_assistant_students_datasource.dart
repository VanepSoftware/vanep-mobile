import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

abstract class AssistantStudentsDataSource {
  Future<AssistantStudentsOverview> findStudentsOverview();
}

// TODO(VAN-73): mocked rosters from the prototype. The students of each van
// need a new endpoint (name, stop, place and absence of the day). Delete this
// class and its registration in assistant_container.dart when it is wired.
class MockedAssistantStudentsDataSource implements AssistantStudentsDataSource {
  const MockedAssistantStudentsDataSource();

  @override
  Future<AssistantStudentsOverview> findStudentsOverview() async {
    return const AssistantStudentsOverview(
      rosters: [
        AssistantStudentsRoster(
          van: AssistantVan(
            token: 'mock-van-carlos',
            driverToken: 'mock-driver-carlos',
            driverName: 'Carlos Mendes',
            plate: 'SDF4E21',
            model: 'Sprinter',
            shift: 'MORNING',
          ),
          students: [
            AssistantStudentSummary(
              token: 'mock-student-ana',
              name: 'Ana Oliveira',
              stopNumber: 3,
              placeName: 'Col. Horizonte',
              isAbsentToday: true,
            ),
            AssistantStudentSummary(
              token: 'mock-student-beatriz',
              name: 'Beatriz Santos',
              stopNumber: 5,
              placeName: 'Jd. das Flores',
            ),
            AssistantStudentSummary(
              token: 'mock-student-davi',
              name: 'Davi Reis',
              stopNumber: 1,
              placeName: 'Vila Nova',
            ),
            AssistantStudentSummary(
              token: 'mock-student-enzo',
              name: 'Enzo Barros',
              stopNumber: 4,
              placeName: 'Res. Aurora',
            ),
            AssistantStudentSummary(
              token: 'mock-student-gabriel',
              name: 'Gabriel Santos',
              stopNumber: 5,
              placeName: 'Jd. das Flores',
            ),
            AssistantStudentSummary(
              token: 'mock-student-helena',
              name: 'Helena Reis',
              stopNumber: 1,
              placeName: 'Vila Nova',
            ),
            AssistantStudentSummary(
              token: 'mock-student-julia',
              name: 'Júlia Barros',
              stopNumber: 4,
              placeName: 'Res. Aurora',
            ),
            AssistantStudentSummary(
              token: 'mock-student-lais',
              name: 'Laís Teixeira',
              stopNumber: 7,
              placeName: 'Escola Classe 10',
            ),
            AssistantStudentSummary(
              token: 'mock-student-laura',
              name: 'Laura Mendes',
              stopNumber: 2,
              placeName: 'Qd. 12',
            ),
            AssistantStudentSummary(
              token: 'mock-student-livia',
              name: 'Lívia Barros',
              stopNumber: 4,
              placeName: 'Res. Aurora',
            ),
            AssistantStudentSummary(
              token: 'mock-student-lucas',
              name: 'Lucas Prado',
              stopNumber: 6,
              placeName: 'Pq. Central',
              isAbsentToday: true,
            ),
            AssistantStudentSummary(
              token: 'mock-student-miguel',
              name: 'Miguel Teixeira',
              stopNumber: 7,
              placeName: 'Escola Classe 10',
            ),
            AssistantStudentSummary(
              token: 'mock-student-pedro',
              name: 'Pedro Oliveira',
              stopNumber: 3,
              placeName: 'Col. Horizonte',
            ),
            AssistantStudentSummary(
              token: 'mock-student-rafael',
              name: 'Rafael Costa',
              stopNumber: 8,
              placeName: 'Qd. 3',
            ),
            AssistantStudentSummary(
              token: 'mock-student-sofia',
              name: 'Sofia Lima',
              stopNumber: 6,
              placeName: 'Pq. Central',
            ),
            AssistantStudentSummary(
              token: 'mock-student-theo',
              name: 'Theo Martins',
              stopNumber: 2,
              placeName: 'Qd. 12',
            ),
          ],
        ),
        AssistantStudentsRoster(
          van: AssistantVan(
            token: 'mock-van-rita',
            driverToken: 'mock-driver-rita',
            driverName: 'Rita Souza',
            plate: 'PBX7C19',
            model: 'Ducato',
            shift: 'AFTERNOON',
          ),
          students: [
            AssistantStudentSummary(
              token: 'mock-student-bruna',
              name: 'Bruna Alves',
              stopNumber: 1,
              placeName: 'Escola Classe 10',
            ),
            AssistantStudentSummary(
              token: 'mock-student-caio',
              name: 'Caio Ribeiro',
              stopNumber: 2,
              placeName: 'Qd. 3',
            ),
            AssistantStudentSummary(
              token: 'mock-student-diego',
              name: 'Diego Nunes',
              stopNumber: 3,
              placeName: 'Vila Nova',
              isAbsentToday: true,
            ),
          ],
        ),
      ],
    );
  }
}
