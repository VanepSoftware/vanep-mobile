import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

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
    required String password,
    bool acceptTerms = true,
  });

  Future<Result<AssistantFailure, List<AssistantVan>>> getLinkedVans();
}
