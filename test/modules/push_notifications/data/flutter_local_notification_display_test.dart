import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/flutter_local_notification_display.dart';

import '../push_notifications_fixtures.dart';
import '../push_notifications_mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late FlutterLocalNotificationDisplay display;

  setUpAll(() => registerFallbackValue(const NotificationDetails()));

  setUp(() {
    plugin = MockFlutterLocalNotificationsPlugin();
    display = FlutterLocalNotificationDisplay(
      plugin: plugin,
      channel: buildPushNotificationChannel(AppLocalizationsPt()),
    );
  });

  test('the notification icon is the Android small-icon drawable', () {
    expect(pushNotificationIcon, '@drawable/ic_stat_notification');
  });

  test('the channel matches the manifest default channel', () {
    expect(display.channel.id, 'vanep_default');
    expect(display.channel.name, 'Notificações');
    expect(display.channel.importance, Importance.high);
  });

  test('shows the message with its data as payload', () async {
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});

    await display.show(chatPushMessage);

    final captured = verify(
      () => plugin.show(
        id: any(named: 'id'),
        title: 'Carlos',
        body: 'Chego em 5 minutos',
        notificationDetails: captureAny(named: 'notificationDetails'),
        payload: jsonEncode(chatPushData),
      ),
    ).captured;
    final details = captured.single as NotificationDetails;
    expect(details.android?.channelId, 'vanep_default');
  });

  test('a tapped notification publishes its data', () async {
    final tapped = display.tappedData.first;

    display.publishTappedData(
      NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: jsonEncode(chatPushData),
      ),
    );

    expect(await tapped, chatPushData);
  });

  test('reads the data of the notification that launched the app', () async {
    when(plugin.getNotificationAppLaunchDetails).thenAnswer(
      (_) async => NotificationAppLaunchDetails(
        true,
        notificationResponse: NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: jsonEncode(chatPushData),
        ),
      ),
    );

    expect(await display.readLaunchData(), chatPushData);
  });

  test(
    'no launch data when the app was not opened by a notification',
    () async {
      when(plugin.getNotificationAppLaunchDetails)
          .thenAnswer((_) async => const NotificationAppLaunchDetails(false));

      expect(await display.readLaunchData(), isNull);
    },
  );

  test('payloads that are not a JSON object decode to null', () {
    expect(decodePushPayload(null), isNull);
    expect(decodePushPayload(''), isNull);
    expect(decodePushPayload('not json'), isNull);
    expect(decodePushPayload('[1]'), isNull);
  });
}
