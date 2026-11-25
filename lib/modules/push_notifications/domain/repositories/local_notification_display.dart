import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';

abstract class LocalNotificationDisplay {
  Future<void> show(PushMessage message);

  Stream<Map<String, Object?>> get tappedData;

  Future<Map<String, Object?>?> readLaunchData();
}
