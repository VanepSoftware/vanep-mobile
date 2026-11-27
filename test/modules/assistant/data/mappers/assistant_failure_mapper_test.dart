import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/modules/assistant/data/mappers/assistant_failure_mapper.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

DioException _error(int? statusCode, [Object? data]) {
  final options = RequestOptions(path: '/api/assistant/invites');
  return DioException(
    requestOptions: options,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: options,
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  test('maps known ProblemDetail codes strictly', () {
    expect(
      mapAssistantFailure(
        _error(410, {'code': ApiErrorCodes.assistantInviteExpired}),
      ),
      AssistantFailure.expiredInvite,
    );
    expect(
      mapAssistantFailure(
        _error(409, {'code': ApiErrorCodes.assistantInviteNotPending}),
      ),
      AssistantFailure.alreadyUsedInvite,
    );
    expect(
      mapAssistantFailure(
        _error(404, {'code': ApiErrorCodes.assistantInviteNotFound}),
      ),
      AssistantFailure.invalidInviteCode,
    );
    expect(
      mapAssistantFailure(
        _error(404, {'code': ApiErrorCodes.assistantInviteEmailNotFound}),
      ),
      AssistantFailure.invalidInviteCode,
    );
    expect(
      mapAssistantFailure(
        _error(403, {'code': ApiErrorCodes.assistantInviteForbidden}),
      ),
      AssistantFailure.unauthorized,
    );
    expect(
      mapAssistantFailure(
        _error(403, {'code': ApiErrorCodes.assistantLinkForbidden}),
      ),
      AssistantFailure.unauthorized,
    );
    expect(
      mapAssistantFailure(
        _error(400, {'code': ApiErrorCodes.validationFailed}),
      ),
      AssistantFailure.invalidPersonalData,
    );
  });

  test('does not match free text in message or detail', () {
    expect(
      mapAssistantFailure(
        _error(409, {'detail': 'convite expired or revoked already_used'}),
      ),
      AssistantFailure.unexpected,
    );
  });

  test('falls back cleanly for unknown code, empty body and network', () {
    expect(mapAssistantFailure(_error(null)), AssistantFailure.network);
    expect(
      mapAssistantFailure(_error(401, {'code': 'unknown'})),
      AssistantFailure.unauthorized,
    );
    expect(
      mapAssistantFailure(_error(404)),
      AssistantFailure.invalidInviteCode,
    );
    expect(
      mapAssistantFailure(_error(400)),
      AssistantFailure.invalidPersonalData,
    );
    expect(
      mapAssistantFailure(_error(500, {'code': 'unknown'})),
      AssistantFailure.unexpected,
    );
  });
}
