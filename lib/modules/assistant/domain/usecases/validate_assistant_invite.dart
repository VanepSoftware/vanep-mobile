import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';

class ValidateAssistantInvite {
  const ValidateAssistantInvite(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, AssistantInvite>> call(String codeOrToken) {
    return repository.validateInvite(codeOrToken);
  }
}
