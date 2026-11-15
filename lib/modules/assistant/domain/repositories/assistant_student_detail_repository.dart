import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';

abstract class AssistantStudentDetailRepository {
  Future<Result<AssistantFailure, AssistantStudentDetail>> findStudentDetail(
    String studentToken,
  );

  Future<Result<AssistantFailure, List<AssistantBoardingHistoryDay>>>
  findBoardingHistory(String studentToken);
}
