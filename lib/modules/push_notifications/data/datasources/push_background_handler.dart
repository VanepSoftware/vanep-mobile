import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:vanep_mobile/modules/push_notifications/data/datasources/firebase_push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/flutter_local_notification_display.dart';

/// Runs in a background isolate. Messages with a `notification` block are
/// already shown by the system; data-only messages that carry a title or body
/// are shown here so they still reach the user.
@pragma('vm:entry-point')
Future<void> showBackgroundPushMessage(RemoteMessage remoteMessage) async {
  if (remoteMessage.notification != null) return;
  final message = pushMessageFromRemote(remoteMessage);
  if (!message.hasVisibleContent) return;
  final display = FlutterLocalNotificationDisplay(
    plugin: FlutterLocalNotificationsPlugin(),
    channel: buildPushNotificationChannel(resolveDeviceLocalizations()),
  );
  await display.initialize();
  await display.show(message);
}
