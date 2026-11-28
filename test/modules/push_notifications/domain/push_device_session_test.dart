import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/failures/push_device_failure.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/usecases/push_device_session.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

import '../push_notifications_fixtures.dart';
import '../push_notifications_mocks.dart';

void main() {
  late MockPushMessagingGateway gateway;
  late MockPushDeviceRepository repository;
  late StreamController<String> tokenRefreshes;
  late PushDeviceSession session;

  setUpAll(() => registerFallbackValue(PushDevicePlatform.android));

  setUp(() {
    gateway = MockPushMessagingGateway();
    repository = MockPushDeviceRepository();
    tokenRefreshes = StreamController<String>.broadcast();
    when(gateway.requestPermission).thenAnswer((_) async => true);
    when(gateway.readToken).thenAnswer((_) async => pushToken);
    when(() => gateway.tokenRefreshes).thenAnswer((_) => tokenRefreshes.stream);
    when(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async => const Ok(null));
    when(() => repository.unregisterDevice(any()))
        .thenAnswer((_) async => const Ok(null));
    session = PushDeviceSession(
      gateway: gateway,
      repository: repository,
      platform: PushDevicePlatform.android,
    );
  });

  tearDown(() => tokenRefreshes.close());

  test('registers the token as an android device', () async {
    await session.onSessionStarted();

    verify(
      () => repository.registerDevice(
        token: pushToken,
        platform: PushDevicePlatform.android,
      ),
    ).called(1);
  });

  test('does not register when notifications are denied', () async {
    when(gateway.requestPermission).thenAnswer((_) async => false);

    await session.onSessionStarted();

    verifyNever(gateway.readToken);
    verifyNever(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    );
  });

  test('re-registers a refreshed token', () async {
    await session.onSessionStarted();

    tokenRefreshes.add(refreshedPushToken);
    await pumpEventQueue();

    verify(
      () => repository.registerDevice(
        token: refreshedPushToken,
        platform: PushDevicePlatform.android,
      ),
    ).called(1);
  });

  test('ending the session unregisters the registered token', () async {
    await session.onSessionStarted();

    await session.onSessionEnding();

    verify(() => repository.unregisterDevice(pushToken)).called(1);
  });

  test('ending the session stops following token refreshes', () async {
    await session.onSessionStarted();
    await session.onSessionEnding();

    tokenRefreshes.add(refreshedPushToken);
    await pumpEventQueue();

    verifyNever(
      () => repository.registerDevice(
        token: refreshedPushToken,
        platform: any(named: 'platform'),
      ),
    );
  });

  test('nothing to unregister when registration failed', () async {
    when(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async => const Err(PushDeviceFailure.network));
    await session.onSessionStarted();

    await session.onSessionEnding();

    verifyNever(() => repository.unregisterDevice(any()));
  });

  test('no token means nothing is registered', () async {
    when(gateway.readToken).thenAnswer((_) async => null);

    await session.onSessionStarted();
    await session.onSessionEnding();

    verifyNever(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    );
    verifyNever(() => repository.unregisterDevice(any()));
  });

  test('a slow unregister does not hold sign-out past the timeout', () async {
    when(() => repository.unregisterDevice(any()))
        .thenAnswer((_) => Completer<Result<PushDeviceFailure, void>>().future);
    final quickSession = PushDeviceSession(
      gateway: gateway,
      repository: repository,
      platform: PushDevicePlatform.android,
      unregisterTimeout: const Duration(milliseconds: 10),
    );
    await quickSession.onSessionStarted();

    await expectLater(
      quickSession.onSessionEnding().timeout(const Duration(seconds: 1)),
      completes,
    );
  });
}
