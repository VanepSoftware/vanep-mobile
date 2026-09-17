import '../../../../core/result/result.dart';
import '../entities/assistant_invite.dart';
import '../entities/assistant_van.dart';
import '../failures/assistant_failure.dart';

abstract class AssistantRepository {
  Future<Result<AssistantFailure, AssistantInvite>> validateInvite(
    String codeOrToken,
  );

  Future<Result<AssistantFailure, void>> registerWithInvite({
    required String inviteToken,
    required String name,
    required String birthDate,
    required String email,
    required String cpf,
  });

  Future<Result<AssistantFailure, List<AssistantVan>>> getLinkedVans();
}
