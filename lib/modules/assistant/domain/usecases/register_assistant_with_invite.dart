import '../../../../core/result/result.dart';
import '../failures/assistant_failure.dart';
import '../repositories/assistant_repository.dart';

class RegisterAssistantWithInvite {
  const RegisterAssistantWithInvite(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, void>> call({
    required String inviteToken,
    required String name,
    required String birthDate,
    required String email,
    required String cpf,
    required String password,
    bool acceptTerms = true,
  }) {
    return repository.registerWithInvite(
      inviteToken: inviteToken,
      name: name,
      birthDate: birthDate,
      email: email,
      cpf: cpf,
      password: password,
      acceptTerms: acceptTerms,
    );
  }
}
