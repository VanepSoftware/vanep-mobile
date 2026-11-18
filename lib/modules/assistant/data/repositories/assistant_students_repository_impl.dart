import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_students_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_students_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

class AssistantStudentsRepositoryImpl implements AssistantStudentsRepository {
  const AssistantStudentsRepositoryImpl({required this.dataSource});

  final AssistantStudentsDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantStudentsOverview>>
  findStudentsOverview() async {
    return Ok(await dataSource.findStudentsOverview());
  }
}
