import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_absences_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_absences_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

class AssistantAbsencesRepositoryImpl implements AssistantAbsencesRepository {
  const AssistantAbsencesRepositoryImpl({required this.dataSource});

  final AssistantAbsencesDataSource dataSource;

  @override
  Future<Result<AssistantFailure, List<AssistantAbsence>>> findAbsences(
    String vanToken,
  ) async {
    return Ok(await dataSource.findAbsences(vanToken));
  }
}
