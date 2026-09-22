import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../dtos/assistant_invite_dto.dart';
import '../dtos/assistant_lean_signup_request_dto.dart';
import '../dtos/assistant_van_dto.dart';

abstract class AssistantRemoteDataSource {
  Future<AssistantInviteDto> validateInvite(String codeOrToken);

  Future<void> registerWithInvite(AssistantLeanSignupRequestDto request);

  Future<List<AssistantVanDto>> fetchLinkedVans();

  Future<void> acceptInvite(String token);

  Future<void> rejectInvite(String token);
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
}
