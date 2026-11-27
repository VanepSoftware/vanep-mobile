import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

const _unauthorizedCodes = {
  ApiErrorCodes.authUnauthenticated,
  ApiErrorCodes.authForbidden,
  ApiErrorCodes.assistantInviteForbidden,
  ApiErrorCodes.assistantLinkForbidden,
};

const _invalidInviteCodes = {
  ApiErrorCodes.assistantInviteNotFound,
  ApiErrorCodes.assistantInviteEmailNotFound,
};

const _invalidPersonalDataCodes = {
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
  ApiErrorCodes.assistantInviteEmailInvalid,
  ApiErrorCodes.assistantInviteEmailRequired,
  ApiErrorCodes.assistantInviteWrongUserType,
  ApiErrorCodes.assistantInviteNotUnlinked,
  ApiErrorCodes.authSignupEmailDuplicate,
  ApiErrorCodes.authSignupDocumentDuplicate,
};

AssistantFailure mapAssistantFailure(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return AssistantFailure.network;

  if (problem.matchesCode(ApiErrorCodes.assistantInviteExpired)) {
    return AssistantFailure.expiredInvite;
  }
  if (problem.matchesCode(ApiErrorCodes.assistantInviteNotPending)) {
    return AssistantFailure.alreadyUsedInvite;
  }
  if (problem.matchesAnyCode(_unauthorizedCodes)) {
    return AssistantFailure.unauthorized;
  }
  if (problem.matchesAnyCode(_invalidInviteCodes)) {
    return AssistantFailure.invalidInviteCode;
  }
  if (problem.matchesAnyCode(_invalidPersonalDataCodes)) {
    return AssistantFailure.invalidPersonalData;
  }

  return switch (problem.status) {
    401 || 403 => AssistantFailure.unauthorized,
    404 => AssistantFailure.invalidInviteCode,
    410 => AssistantFailure.expiredInvite,
    400 => AssistantFailure.invalidPersonalData,
    _ => AssistantFailure.unexpected,
  };
}
