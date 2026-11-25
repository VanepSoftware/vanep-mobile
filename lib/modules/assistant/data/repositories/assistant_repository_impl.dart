import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
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
    return guardInviteCall(() => remote.validateInvite(codeOrToken));
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
    return guardInviteCall(() => remote.registerWithInvite(dto));
  }

  @override
  Future<Result<AssistantFailure, List<AssistantVan>>> getLinkedVans() {
    return guardAssistantCall(remote.fetchLinkedVans);
  }

  @override
  Future<Result<AssistantFailure, void>> acceptInvite(String token) {
    return guardInviteCall(() => remote.acceptInvite(token));
  }

  @override
  Future<Result<AssistantFailure, void>> rejectInvite(String token) {
    return guardInviteCall(() => remote.rejectInvite(token));
  }

  @override
  Future<Result<AssistantFailure, List<AssistantTripStop>>> getActiveTripRoute(
    String vanToken,
  ) {
    return guardRouteCall(() => remote.fetchActiveTripRoute(vanToken));
  }

  @override
  Future<Result<AssistantFailure, void>> updateChecklistStatus({
    required String vanToken,
    required List<String> studentTokens,
    required BoardingStatus status,
    required ConfirmationSource confirmedBy,
  }) {
    return guardRouteCall(
      () => remote.updateChecklistStatus(
        vanToken: vanToken,
        studentTokens: studentTokens,
        status: status,
        confirmedBy: confirmedBy,
      ),
    );
  }

  @override
  Future<Result<AssistantFailure, void>> recordNoShow({
    required String vanToken,
    required String studentToken,
    required NoShowReason reason,
    ConfirmationSource confirmedBy = ConfirmationSource.assistant,
  }) {
    return guardRouteCall(
      () => remote.recordNoShow(
        vanToken: vanToken,
        studentToken: studentToken,
        reason: reason,
        confirmedBy: confirmedBy,
      ),
    );
  }
}

Future<Result<AssistantFailure, T>> guardInviteCall<T>(
  Future<T> Function() call,
) {
  return guardAssistantCall(call, notFound: AssistantFailure.invalidInviteCode);
}

Future<Result<AssistantFailure, T>> guardRouteCall<T>(
  Future<T> Function() call,
) {
  return guardAssistantCall(call, notFound: AssistantFailure.routeUnavailable);
}

Future<Result<AssistantFailure, T>> guardAssistantCall<T>(
  Future<T> Function() call, {
  AssistantFailure notFound = AssistantFailure.unexpected,
}) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(mapAssistantFailure(exception, notFound: notFound));
  } on FormatException {
    return const Err(AssistantFailure.unexpected);
  } catch (_) {
    return const Err(AssistantFailure.unexpected);
  }
}
