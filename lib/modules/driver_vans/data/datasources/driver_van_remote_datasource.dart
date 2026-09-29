import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/network/photo_uploader.dart';
import '../../domain/value_objects/van_photo_side.dart';
import '../../domain/value_objects/van_registration.dart';
import '../dtos/driver_van_dto.dart';

class DriverVanRemoteDataSource {
  const DriverVanRemoteDataSource({
    required this.dio,
    required this.environment,
    required this.photoUploader,
  });

  final Dio dio;
  final Environment environment;
  final PhotoUploader photoUploader;

  Future<List<DriverVanDto>> fetchMyVans() async {
    final response = await dio.get<List<dynamic>>(
      environment.myVehiclesEndpoint,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((json) => DriverVanDto.fromJson(Map<String, Object?>.from(json)))
        .toList();
  }

  Future<DriverVanDto> registerVan(VanRegistration registration) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.myVehiclesEndpoint,
      data: vanRegistrationBody(registration),
    );
    return DriverVanDto.fromJson(
      Map<String, Object?>.from(response.data ?? const {}),
    );
  }

  Future<void> uploadVanPhoto(
    String vanToken,
    VanPhotoSide side,
    PickedPhoto photo,
  ) {
    return photoUploader.upload(
      environment.vehiclePhotoEndpoint(vanToken, vanPhotoSlotName(side)),
      photo,
    );
  }
}

Map<String, Object?> vanRegistrationBody(VanRegistration registration) {
  return {
    'plate': registration.normalizedPlate,
    'brand': registration.brand.trim(),
    'model': registration.model.trim(),
    'manufactureYear': registration.parsedManufactureYear,
    'color': registration.color.trim(),
    'capacity': registration.parsedCapacity,
  };
}

String vanPhotoSlotName(VanPhotoSide side) {
  return switch (side) {
    VanPhotoSide.front => 'photo-front',
    VanPhotoSide.side => 'photo-side',
  };
}
