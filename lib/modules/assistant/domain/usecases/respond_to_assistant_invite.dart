import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';

enum InviteResponse { accept, reject }

class RespondToAssistantInvite {
  const RespondToAssistantInvite(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, void>> call(
    String token,
    InviteResponse response,
  ) {
    return switch (response) {
      InviteResponse.accept => repository.acceptInvite(token),
      InviteResponse.reject => repository.rejectInvite(token),
    };
  }
}
