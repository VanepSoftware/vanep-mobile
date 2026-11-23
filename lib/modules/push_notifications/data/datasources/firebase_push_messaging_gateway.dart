import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';

typedef ReportPushError = void Function(Object error, StackTrace stackTrace);

const pushDataTitleKey = 'title';

const pushDataBodyKey = 'body';

class FirebasePushMessagingGateway implements PushMessagingGateway {
  const FirebasePushMessagingGateway({
    required this.messaging,
    required this.reportError,
  });

  final FirebaseMessaging messaging;

  final ReportPushError reportError;

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await messaging.requestPermission();
      return isPushPermissionGranted(settings.authorizationStatus);
    } on FirebaseException catch (error, stackTrace) {
      reportError(error, stackTrace);
      return false;
    }
  }

  @override
  Future<String?> readToken() async {
    try {
      // The API sends to FCM registration tokens. register()/onRegistered
      // yield a Firebase Installation ID instead, which needs backend support.
      // ignore: deprecated_member_use
      return await messaging.getToken();
    } on FirebaseException catch (error, stackTrace) {
      // Devices without Google Play services (or offline) fail here; the
      // session keeps working and onTokenRefresh retries the registration.
      reportError(error, stackTrace);
      return null;
    }
  }

  @override
  // ignore: deprecated_member_use
  Stream<String> get tokenRefreshes => messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage.map(pushMessageFromRemote);

  @override
  Stream<PushMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp.map(pushMessageFromRemote);

  @override
  Future<PushMessage?> readLaunchMessage() async {
    final message = await messaging.getInitialMessage();
    return message == null ? null : pushMessageFromRemote(message);
  }
}

bool isPushPermissionGranted(AuthorizationStatus status) {
  return status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}

PushMessage pushMessageFromRemote(RemoteMessage message) {
  final data = Map<String, Object?>.from(message.data);
  return PushMessage(
    title:
        message.notification?.title ??
        readOptionalString(data, pushDataTitleKey),
    body:
        message.notification?.body ?? readOptionalString(data, pushDataBodyKey),
    data: data,
  );
}

String? readOptionalString(Map<String, Object?> data, String key) {
  final value = data[key];
  return value is String ? value : null;
}
