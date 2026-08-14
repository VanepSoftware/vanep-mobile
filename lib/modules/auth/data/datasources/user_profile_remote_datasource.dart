import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../dtos/user_profile_dto.dart';

class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<UserProfileDto> fetchMe() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.userProfileEndpoint,
    );
    return UserProfileDto.fromJson(response.data!);
  }

  Future<UserProfileDto> patchMe(Map<String, Object?> body) async {
    final response = await dio.patch<Map<String, dynamic>>(
      environment.userProfileEndpoint,
      data: body,
    );
    return UserProfileDto.fromJson(response.data!);
  }

  Future<void> requestEmailChange(String email) async {
    await dio.post<void>(
      environment.userProfileEmailChangeEndpoint,
      data: {'email': email},
    );
  }
}
