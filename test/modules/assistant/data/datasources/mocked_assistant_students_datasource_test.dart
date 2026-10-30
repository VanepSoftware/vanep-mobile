import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_students_datasource.dart';

void main() {
  const dataSource = MockedAssistantStudentsDataSource();

  test('offers a roster for each of the two vans', () async {
    final overview = await dataSource.findStudentsOverview();

    expect(overview.rosters, hasLength(2));
    expect(overview.rosters.first.students, hasLength(16));
  });

  test('marks two students of the first van as absent today', () async {
    final overview = await dataSource.findStudentsOverview();

    final absent = overview.rosters.first.students
        .where((student) => student.isAbsentToday)
        .map((student) => student.name);
    expect(absent, ['Ana Oliveira', 'Lucas Prado']);
  });
}
