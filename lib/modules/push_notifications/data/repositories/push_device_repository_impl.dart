import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/push_device_remote_datasource.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/failures/push_device_failure.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_device_repository.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

PushDeviceFailure pushDeviceFailureFrom(DioException exception) {
  return exception.response == null
      ? PushDeviceFailure.network
      : PushDeviceFailure.unexpected;
}

class PushDeviceRepositoryImpl implements PushDeviceRepository {
  const PushDeviceRepositoryImpl({required this.remote});

  final PushDeviceRemoteDataSource remote;

  @override
  Future<Result<PushDeviceFailure, void>> registerDevice({
    required String token,
    required PushDevicePlatform platform,
  }) async {
    try {
      await remote.registerDevice(token: token, platform: platform);
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(pushDeviceFailureFrom(exception));
    }
  }

  @override
  Future<Result<PushDeviceFailure, void>> unregisterDevice(String token) async {
    try {
      await remote.unregisterDevice(token);
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(pushDeviceFailureFrom(exception));
    }
  }
}
