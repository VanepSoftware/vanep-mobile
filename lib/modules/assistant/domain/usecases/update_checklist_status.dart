import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';

class UpdateChecklistStatus {
  const UpdateChecklistStatus(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, void>> call({
    required String vanToken,
    required List<String> studentTokens,
    required BoardingStatus status,
    ConfirmationSource confirmedBy = ConfirmationSource.assistant,
  }) {
    return repository.updateChecklistStatus(
      vanToken: vanToken,
      studentTokens: studentTokens,
      status: status,
      confirmedBy: confirmedBy,
    );
  }
}
