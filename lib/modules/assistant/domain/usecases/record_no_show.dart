import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

class RecordNoShow {
  const RecordNoShow(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, void>> call({
    required String vanToken,
    required String studentToken,
    required NoShowReason reason,
  }) {
    return repository.recordNoShow(
      vanToken: vanToken,
      studentToken: studentToken,
      reason: reason,
    );
  }
}
