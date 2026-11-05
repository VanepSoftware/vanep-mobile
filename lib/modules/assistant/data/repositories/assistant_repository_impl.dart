import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_lean_signup_request_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/mappers/assistant_failure_mapper.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  const AssistantRepositoryImpl({required this.remote});

  final AssistantRemoteDataSource remote;

  @override
  Future<Result<AssistantFailure, AssistantInvite>> validateInvite(
    String codeOrToken,
  ) {
    return guardAssistantCall(() => remote.validateInvite(codeOrToken));
  }

  @override
  Future<Result<AssistantFailure, void>> registerWithInvite({
    required String inviteToken,
    required String name,
    required String birthDate,
    required String email,
    required String cpf,
    required String password,
    bool acceptTerms = true,
  }) {
    final dto = AssistantLeanSignupRequestDto(
      inviteToken: inviteToken,
      name: name,
      birthDate: birthDate,
      email: email,
      cpf: cpf,
      password: password,
      acceptTerms: acceptTerms,
    );
    return guardAssistantCall(() => remote.registerWithInvite(dto));
  }

  @override
  Future<Result<AssistantFailure, List<AssistantVan>>> getLinkedVans() {
    return guardAssistantCall(remote.fetchLinkedVans);
  }
}

Future<Result<AssistantFailure, T>> guardAssistantCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(mapAssistantFailure(exception));
  } on FormatException {
    return const Err(AssistantFailure.unexpected);
  } catch (_) {
    return const Err(AssistantFailure.unexpected);
  }
}
