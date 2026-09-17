import '../../../../core/result/result.dart';
import '../entities/assistant_invite.dart';
import '../failures/assistant_failure.dart';
import '../repositories/assistant_repository.dart';

class ValidateAssistantInvite {
  const ValidateAssistantInvite(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, AssistantInvite>> call(String codeOrToken) {
    return repository.validateInvite(codeOrToken);
  }
}
