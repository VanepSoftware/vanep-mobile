import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_students_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

class FindAssistantStudents {
  const FindAssistantStudents(this.repository);

  final AssistantStudentsRepository repository;

  Future<Result<AssistantFailure, AssistantStudentsOverview>> call() {
    return repository.findStudentsOverview();
  }
}
