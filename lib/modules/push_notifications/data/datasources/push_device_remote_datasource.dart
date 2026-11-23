import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

class PushDeviceRemoteDataSource {
  const PushDeviceRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;

  final Environment environment;

  Future<void> registerDevice({
    required String token,
    required PushDevicePlatform platform,
  }) async {
    await dio.post<void>(
      environment.devicesEndpoint,
      data: {'token': token, 'platform': platform.apiName},
    );
  }

  Future<void> unregisterDevice(String token) async {
    await dio.delete<void>(environment.deviceEndpoint(token));
  }
}
