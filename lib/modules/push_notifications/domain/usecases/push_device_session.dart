import 'dart:async';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/session/session_lifecycle_observer.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_device_repository.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';

const defaultUnregisterDeviceTimeout = Duration(seconds: 5);

class PushDeviceSession implements SessionLifecycleObserver {
  PushDeviceSession({
    required this.gateway,
    required this.repository,
    required this.platform,
    this.unregisterTimeout = defaultUnregisterDeviceTimeout,
  });

  final PushMessagingGateway gateway;

  final PushDeviceRepository repository;

  final PushDevicePlatform platform;

  final Duration unregisterTimeout;

  StreamSubscription<String>? tokenRefreshSubscription;

  String? registeredToken;

  @override
  Future<void> onSessionStarted() async {
    if (!await gateway.requestPermission()) return;
    await tokenRefreshSubscription?.cancel();
    tokenRefreshSubscription = gateway.tokenRefreshes.listen(registerToken);
    final token = await gateway.readToken();
    if (token != null) await registerToken(token);
  }

  Future<void> registerToken(String token) async {
    final result = await repository.registerDevice(
      token: token,
      platform: platform,
    );
    if (result.isOk) registeredToken = token;
  }

  @override
  Future<void> onSessionEnding() async {
    await tokenRefreshSubscription?.cancel();
    tokenRefreshSubscription = null;
    final token = registeredToken;
    registeredToken = null;
    if (token == null) return;
    await repository
        .unregisterDevice(token)
        .timeout(unregisterTimeout, onTimeout: () => const Ok(null));
  }
}
