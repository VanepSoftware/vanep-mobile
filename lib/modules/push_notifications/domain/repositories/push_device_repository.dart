import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/failures/push_device_failure.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

abstract class PushDeviceRepository {
  Future<Result<PushDeviceFailure, void>> registerDevice({
    required String token,
    required PushDevicePlatform platform,
  });

  Future<Result<PushDeviceFailure, void>> unregisterDevice(String token);
}
