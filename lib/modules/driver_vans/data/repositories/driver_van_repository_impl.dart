import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/repositories/driver_van_repository.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';
import 'package:vanep_mobile/modules/driver_vans/data/datasources/driver_van_remote_datasource.dart';

class DriverVanRepositoryImpl implements DriverVanRepository {
  const DriverVanRepositoryImpl({required this.remote});

  final DriverVanRemoteDataSource remote;

  @override
  Future<Result<DriverVanFailure, List<DriverVan>>> listMyVans() async {
    try {
      return Ok(await remote.fetchMyVans());
    } on DioException catch (error) {
      return Err(driverVanFailureFrom(error));
    }
  }

  @override
  Future<Result<DriverVanFailure, DriverVan>> registerVan(
    VanRegistration registration,
  ) async {
    try {
      return Ok(await remote.registerVan(registration));
    } on DioException catch (error) {
      return Err(driverVanFailureFrom(error));
    }
  }

  @override
  Future<Result<PhotoFailure, void>> uploadVanPhoto(
    String vanToken,
    VanPhotoSide side,
    PickedPhoto photo,
  ) async {
    try {
      await remote.uploadVanPhoto(vanToken, side, photo);
      return const Ok(null);
    } on DioException catch (error) {
      return Err(photoFailureFrom(error));
    }
  }
}

DriverVanFailure driverVanFailureFrom(DioException error) {
  return switch (error.response?.statusCode) {
    null => DriverVanFailure.network,
    409 => DriverVanFailure.duplicatePlate,
    400 => DriverVanFailure.invalidData,
    _ => DriverVanFailure.unexpected,
  };
}
