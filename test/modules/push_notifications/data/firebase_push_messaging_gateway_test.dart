// ignore_for_file: deprecated_member_use
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/firebase_push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';

import '../push_notifications_fixtures.dart';
import '../push_notifications_mocks.dart';

NotificationSettings notificationSettings(AuthorizationStatus status) {
  return NotificationSettings(
    alert: AppleNotificationSetting.notSupported,
    announcement: AppleNotificationSetting.notSupported,
    authorizationStatus: status,
    badge: AppleNotificationSetting.notSupported,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.notSupported,
    notificationCenter: AppleNotificationSetting.notSupported,
    showPreviews: AppleShowPreviewSetting.notSupported,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    sound: AppleNotificationSetting.notSupported,
    providesAppNotificationSettings: AppleNotificationSetting.notSupported,
  );
}

void main() {
  late MockFirebaseMessaging messaging;
  late List<Object> reportedErrors;
  late FirebasePushMessagingGateway gateway;

  setUp(() {
    messaging = MockFirebaseMessaging();
    reportedErrors = [];
    gateway = FirebasePushMessagingGateway(
      messaging: messaging,
      reportError: (error, _) => reportedErrors.add(error),
    );
  });

  group('requestPermission', () {
    for (final (status, granted) in [
      (AuthorizationStatus.authorized, true),
      (AuthorizationStatus.provisional, true),
      (AuthorizationStatus.denied, false),
      (AuthorizationStatus.notDetermined, false),
    ]) {
      test('$status is granted: $granted', () async {
        when(messaging.requestPermission)
            .thenAnswer((_) async => notificationSettings(status));

        expect(await gateway.requestPermission(), granted);
      });
    }

    test('a Firebase error is reported and treated as denied', () async {
      when(messaging.requestPermission).thenThrow(
        FirebaseException(plugin: 'firebase_messaging', code: 'unknown'),
      );

      expect(await gateway.requestPermission(), isFalse);
      expect(reportedErrors, hasLength(1));
    });
  });

  group('readToken', () {
    test('returns the FCM token', () async {
      when(messaging.getToken).thenAnswer((_) async => pushToken);

      expect(await gateway.readToken(), pushToken);
    });

    test('a Firebase error is reported and yields no token', () async {
      when(messaging.getToken).thenThrow(
        FirebaseException(
          plugin: 'firebase_messaging',
          code: 'SERVICE_NOT_AVAILABLE',
        ),
      );

      expect(await gateway.readToken(), isNull);
      expect(reportedErrors, hasLength(1));
    });
  });

  test('the launch message is mapped to a push message', () async {
    when(messaging.getInitialMessage).thenAnswer(
      (_) async => const RemoteMessage(
        data: chatPushData,
        notification: RemoteNotification(
          title: 'Carlos',
          body: 'Chego em 5 minutos',
        ),
      ),
    );

    expect(await gateway.readLaunchMessage(), chatPushMessage);
  });

  test('no launch message yields null', () async {
    when(messaging.getInitialMessage).thenAnswer((_) async => null);

    expect(await gateway.readLaunchMessage(), isNull);
  });

  test('a data-only message takes its text from the data', () {
    expect(
      pushMessageFromRemote(
        const RemoteMessage(
          data: {'type': 'proposta', 'title': 'Nova proposta'},
        ),
      ),
      const PushMessage(
        title: 'Nova proposta',
        data: {'type': 'proposta', 'title': 'Nova proposta'},
      ),
    );
  });
}
