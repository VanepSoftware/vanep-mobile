import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_student_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';

class FindAssistantStudentDetail {
  const FindAssistantStudentDetail(this.repository);

  final AssistantStudentDetailRepository repository;

  Future<Result<AssistantFailure, AssistantStudentDetail>> call(
    String studentToken,
  ) {
    return repository.findStudentDetail(studentToken);
  }
}
