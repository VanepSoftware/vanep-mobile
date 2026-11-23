import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/local_notification_display.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';

/// Must match `com.google.firebase.messaging.default_notification_channel_id`
/// in AndroidManifest.xml, so background notifications share the channel.
const pushNotificationChannelId = 'vanep_default';

const pushNotificationIcon = '@mipmap/ic_launcher';

class FlutterLocalNotificationDisplay implements LocalNotificationDisplay {
  FlutterLocalNotificationDisplay({
    required this.plugin,
    required this.channel,
  });

  final FlutterLocalNotificationsPlugin plugin;

  final AndroidNotificationChannel channel;

  final StreamController<Map<String, Object?>> tappedDataController =
      StreamController.broadcast();

  Future<void> initialize() async {
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(pushNotificationIcon),
      ),
      onDidReceiveNotificationResponse: publishTappedData,
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void publishTappedData(NotificationResponse response) {
    final data = decodePushPayload(response.payload);
    if (data != null) tappedDataController.add(data);
  }

  @override
  Future<void> show(PushMessage message) {
    return plugin.show(
      id: nextNotificationId(),
      title: message.title,
      body: message.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  @override
  Stream<Map<String, Object?>> get tappedData => tappedDataController.stream;

  @override
  Future<Map<String, Object?>?> readLaunchData() async {
    final details = await plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return decodePushPayload(details.notificationResponse?.payload);
  }
}

AndroidNotificationChannel buildPushNotificationChannel(AppLocalizations l10n) {
  return AndroidNotificationChannel(
    pushNotificationChannelId,
    l10n.pushNotificationChannelName,
    description: l10n.pushNotificationChannelDescription,
    importance: Importance.high,
  );
}

AppLocalizations resolveDeviceLocalizations() {
  return lookupAppLocalizations(
    basicLocaleListResolution(
      PlatformDispatcher.instance.locales,
      AppLocalizations.supportedLocales,
    ),
  );
}

int nextNotificationId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
}

Map<String, Object?>? decodePushPayload(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map ? Map<String, Object?>.from(decoded) : null;
  } on FormatException {
    return null;
  }
}
