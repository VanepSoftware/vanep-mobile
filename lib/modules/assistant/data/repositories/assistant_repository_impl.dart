import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/assistant_invite.dart';
import '../../domain/entities/assistant_van.dart';
import '../../domain/failures/assistant_failure.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_datasource.dart';
import '../dtos/assistant_lean_signup_request_dto.dart';
import '../mappers/assistant_failure_mapper.dart';

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
  }) {
    final dto = AssistantLeanSignupRequestDto(
      inviteToken: inviteToken,
      name: name,
      birthDate: birthDate,
      email: email,
      cpf: cpf,
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
