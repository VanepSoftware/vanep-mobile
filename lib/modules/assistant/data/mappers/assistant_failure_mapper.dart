import 'package:dio/dio.dart';

import '../../domain/failures/assistant_failure.dart';

AssistantFailure mapAssistantFailure(DioException exception) {
  final response = exception.response;
  if (response == null) return AssistantFailure.network;

  final statusCode = response.statusCode;
  if (statusCode == 401 || statusCode == 403) {
    return AssistantFailure.unauthorized;
  }
  if (statusCode == 404) {
    return AssistantFailure.invalidInviteCode;
  }

  final body = response.data;
  final code = _extractErrorCode(body);

  if (code.contains('expired')) {
    return AssistantFailure.expiredInvite;
  }
  if (code.contains('already_used') || code.contains('alreadyused')) {
    return AssistantFailure.alreadyUsedInvite;
  }
  if (code.contains('revoked')) {
    return AssistantFailure.revokedInvite;
  }
  if (code.contains('invalid_code') || code.contains('not_found')) {
    return AssistantFailure.invalidInviteCode;
  }
  if (statusCode == 400 || code.contains('validation')) {
    return AssistantFailure.invalidPersonalData;
  }

  return AssistantFailure.unexpected;
}

String _extractErrorCode(Object? body) {
  if (body is Map) {
    final code = body['code'] ?? body['error'] ?? body['message'];
    if (code is String) return code.toLowerCase();
  }
  if (body is String) {
    return body.toLowerCase();
  }
  return '';
}
