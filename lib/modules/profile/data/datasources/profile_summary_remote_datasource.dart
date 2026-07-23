import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../../domain/entities/profile_summary.dart';
import '../dtos/profile_summary_dto.dart';

class ProfileSummaryRemoteDataSource {
  ProfileSummaryRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<ProfileSummary> fetchSummary(UserType type) async {
    final endpoint = profileSummaryEndpointFor(type, environment);
    final response = await dio.get<Map<String, dynamic>>(endpoint);
    final data = response.data;
    if (data == null) {
      throw StateError('Empty profile summary response');
    }
    final json = Map<String, Object?>.from(data);
    return switch (type) {
      UserType.client => ClientProfileSummaryDto.fromJson(json),
      UserType.driver => DriverProfileSummaryDto.fromJson(json),
      UserType.assistant => AssistantProfileSummaryDto.fromJson(json),
      UserType.admin => throw UnsupportedError('ADMIN has no profile summary'),
    };
  }
}

String profileSummaryEndpointFor(UserType type, Environment environment) {
  return switch (type) {
    UserType.client => environment.clientsMeEndpoint,
    UserType.driver => environment.driversMeEndpoint,
    UserType.assistant => environment.assistantsMeEndpoint,
    UserType.admin => throw UnsupportedError('ADMIN has no profile summary'),
  };
}
