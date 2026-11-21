import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_student_detail_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_student_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';

class AssistantStudentDetailRepositoryImpl
    implements AssistantStudentDetailRepository {
  const AssistantStudentDetailRepositoryImpl({required this.dataSource});

  final AssistantStudentDetailDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantStudentDetail>> findStudentDetail(
    String studentToken,
  ) async {
    return Ok(await dataSource.findStudentDetail(studentToken));
  }

  @override
  Future<Result<AssistantFailure, List<AssistantBoardingHistoryDay>>>
  findBoardingHistory(String studentToken) async {
    return Ok(await dataSource.findBoardingHistory(studentToken));
  }
}
