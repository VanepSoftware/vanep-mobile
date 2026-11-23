import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/usecases/push_message_router.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';

import '../push_notifications_fixtures.dart';
import '../push_notifications_mocks.dart';

void main() {
  late MockPushMessagingGateway gateway;
  late MockLocalNotificationDisplay display;
  late StreamController<PushMessage> foregroundMessages;
  late StreamController<PushMessage> openedMessages;
  late StreamController<Map<String, Object?>> tappedData;
  late List<PushNavigationTarget> openedTargets;
  late PushMessageRouter router;

  setUpAll(() => registerFallbackValue(silentPushMessage));

  setUp(() {
    gateway = MockPushMessagingGateway();
    display = MockLocalNotificationDisplay();
    foregroundMessages = StreamController<PushMessage>.broadcast();
    openedMessages = StreamController<PushMessage>.broadcast();
    tappedData = StreamController<Map<String, Object?>>.broadcast();
    openedTargets = [];
    when(() => gateway.foregroundMessages)
        .thenAnswer((_) => foregroundMessages.stream);
    when(() => gateway.openedMessages).thenAnswer((_) => openedMessages.stream);
    when(gateway.readLaunchMessage).thenAnswer((_) async => null);
    when(() => display.tappedData).thenAnswer((_) => tappedData.stream);
    when(display.readLaunchData).thenAnswer((_) async => null);
    when(() => display.show(any())).thenAnswer((_) async {});
    router = PushMessageRouter(
      gateway: gateway,
      display: display,
      openTarget: openedTargets.add,
    );
  });

  tearDown(() async {
    await router.stop();
    await foregroundMessages.close();
    await openedMessages.close();
    await tappedData.close();
  });

  test('shows a foreground message as a local notification', () async {
    await router.start();

    foregroundMessages.add(chatPushMessage);
    await pumpEventQueue();

    verify(() => display.show(chatPushMessage)).called(1);
  });

  test('does not show a foreground message without text', () async {
    await router.start();

    foregroundMessages.add(silentPushMessage);
    await pumpEventQueue();

    verifyNever(() => display.show(any()));
  });

  test('opens the target of a notification tapped in background', () async {
    await router.start();

    openedMessages.add(chatPushMessage);
    await pumpEventQueue();

    expect(openedTargets, [chatPushTarget]);
  });

  test('opens the target of a tapped local notification', () async {
    await router.start();

    tappedData.add(chatPushData);
    await pumpEventQueue();

    expect(openedTargets, [chatPushTarget]);
  });

  test('opens the target of the push that launched the app', () async {
    when(gateway.readLaunchMessage).thenAnswer((_) async => chatPushMessage);

    await router.start();

    expect(openedTargets, [chatPushTarget]);
    verifyNever(display.readLaunchData);
  });

  test(
    'opens the target of the local notification that launched the app',
    () async {
      when(display.readLaunchData).thenAnswer((_) async => chatPushData);

      await router.start();

      expect(openedTargets, [chatPushTarget]);
    },
  );

  test('ignores taps without a known target', () async {
    await router.start();

    tappedData.add(const {'type': 'promo'});
    await pumpEventQueue();

    expect(openedTargets, isEmpty);
  });

  test('stops listening after stop', () async {
    await router.start();
    await router.stop();

    tappedData.add(chatPushData);
    await pumpEventQueue();

    expect(openedTargets, isEmpty);
  });
}
