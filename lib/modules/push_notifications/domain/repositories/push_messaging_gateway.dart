import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';

abstract class PushMessagingGateway {
  Future<bool> requestPermission();

  Future<String?> readToken();

  Stream<String> get tokenRefreshes;

  Stream<PushMessage> get foregroundMessages;

  Stream<PushMessage> get openedMessages;

  Future<PushMessage?> readLaunchMessage();
}
