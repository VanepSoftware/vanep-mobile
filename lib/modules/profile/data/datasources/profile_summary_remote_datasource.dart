import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/network/photo_uploader.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../../domain/entities/profile_summary.dart';
import '../dtos/profile_summary_dto.dart';

class ProfileSummaryRemoteDataSource {
  ProfileSummaryRemoteDataSource({
    required this.dio,
    required this.environment,
    required this.photoUploader,
  });

  final Dio dio;
  final Environment environment;
  final PhotoUploader photoUploader;

  Future<void> uploadPhoto(ProfileSummary owner, PickedPhoto photo) {
    return photoUploader.upload(
      profilePhotoEndpointFor(owner, environment),
      photo,
    );
  }

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

String profilePhotoEndpointFor(ProfileSummary owner, Environment environment) {
  final ownersEndpoint = switch (owner) {
    ClientProfileSummary() => environment.clientsEndpoint,
    DriverProfileSummary() => environment.driversEndpoint,
    AssistantProfileSummary() => environment.assistantsEndpoint,
  };
  return '$ownersEndpoint/${Uri.encodeComponent(owner.token)}/photo';
}
