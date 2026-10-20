import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_invite_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_lean_signup_request_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_trip_checklist_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_van_dto.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

abstract class AssistantRemoteDataSource {
  Future<AssistantInviteDto> validateInvite(String codeOrToken);

  Future<void> registerWithInvite(AssistantLeanSignupRequestDto request);

  Future<List<AssistantVanDto>> fetchLinkedVans();

  Future<void> acceptInvite(String token);

  Future<void> rejectInvite(String token);

  Future<List<AssistantTripStopDto>> fetchActiveTripRoute(String vanToken);

  Future<void> updateChecklistStatus({
    required String vanToken,
    required List<String> studentTokens,
    required BoardingStatus status,
    required ConfirmationSource confirmedBy,
  });

  Future<void> recordNoShow({
    required String vanToken,
    required String studentToken,
    required NoShowReason reason,
    required ConfirmationSource confirmedBy,
  });
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  AssistantRemoteDataSourceImpl({
    required this.dio,
    required this.environment,
  });

  final Dio dio;

  final Environment environment;

  @override
  Future<AssistantInviteDto> validateInvite(String codeOrToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      '${environment.assistantsMeEndpoint}/invite',
      queryParameters: {'code': codeOrToken},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty invite response.');
    }
    return AssistantInviteDto.fromJson(Map<String, Object?>.from(data));
  }

  @override
  Future<void> registerWithInvite(AssistantLeanSignupRequestDto request) async {
    await dio.post<void>(
      environment.signupAssistantEndpoint,
      data: request.toJson(),
    );
  }

  @override
  Future<List<AssistantVanDto>> fetchLinkedVans() async {
    final response = await dio.get<List<dynamic>>(
      '${environment.assistantsMeEndpoint}/vans',
    );
    final list = response.data;
    if (list == null) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => AssistantVanDto.fromJson(Map<String, Object?>.from(e)))
        .toList();
  }

  @override
  Future<void> acceptInvite(String token) async {
    await dio.post<void>(
      '${environment.assistantsMeEndpoint}/invite/accept',
      data: {'token': token},
    );
  }

  @override
  Future<void> rejectInvite(String token) async {
    await dio.post<void>(
      '${environment.assistantsMeEndpoint}/invite/reject',
      data: {'token': token},
    );
  }

  @override
  Future<List<AssistantTripStopDto>> fetchActiveTripRoute(
    String vanToken,
  ) async {
    final response = await dio.get<List<dynamic>>(
      '${environment.assistantsMeEndpoint}/vans/$vanToken/route',
    );
    final list = response.data;
    if (list == null) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => AssistantTripStopDto.fromJson(Map<String, Object?>.from(e)))
        .toList();
  }

  @override
  Future<void> updateChecklistStatus({
    required String vanToken,
    required List<String> studentTokens,
    required BoardingStatus status,
    required ConfirmationSource confirmedBy,
  }) async {
    await dio.post<void>(
      '${environment.assistantsMeEndpoint}/vans/$vanToken/checklist/status',
      data: {
        'student_tokens': studentTokens,
        'status': BoardingStatus.toApi(status),
        'confirmed_by': ConfirmationSource.toApi(confirmedBy),
      },
    );
  }

  @override
  Future<void> recordNoShow({
    required String vanToken,
    required String studentToken,
    required NoShowReason reason,
    required ConfirmationSource confirmedBy,
  }) async {
    await dio.post<void>(
      '${environment.assistantsMeEndpoint}/vans/$vanToken/checklist/no-show',
      data: {
        'student_token': studentToken,
        'reason': NoShowReason.toApi(reason),
        'confirmed_by': ConfirmationSource.toApi(confirmedBy),
      },
    );
  }
}
