import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

abstract class AssistantAbsencesRepository {
  Future<Result<AssistantFailure, List<AssistantAbsence>>> findAbsences(
    String vanToken,
  );
}
