import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

abstract class AssistantStudentsRepository {
  Future<Result<AssistantFailure, AssistantStudentsOverview>>
  findStudentsOverview();
}
