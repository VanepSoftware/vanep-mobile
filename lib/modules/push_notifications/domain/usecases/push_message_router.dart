import 'dart:async';

import 'package:vanep_mobile/modules/push_notifications/domain/repositories/local_notification_display.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_message.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';

typedef OpenPushTarget = void Function(PushNavigationTarget target);

class PushMessageRouter {
  PushMessageRouter({
    required this.gateway,
    required this.display,
    required this.openTarget,
  });

  final PushMessagingGateway gateway;

  final LocalNotificationDisplay display;

  final OpenPushTarget openTarget;

  final List<StreamSubscription<Object?>> subscriptions = [];

  Future<void> start() async {
    subscriptions.addAll([
      gateway.foregroundMessages.listen(showForegroundMessage),
      gateway.openedMessages.listen((message) => openTargetFor(message.data)),
      display.tappedData.listen(openTargetFor),
    ]);
    final launchData =
        (await gateway.readLaunchMessage())?.data ??
        await display.readLaunchData();
    if (launchData != null) openTargetFor(launchData);
  }

  Future<void> showForegroundMessage(PushMessage message) async {
    if (message.hasVisibleContent) await display.show(message);
  }

  void openTargetFor(Map<String, Object?> data) {
    final target = pushNavigationTargetFrom(data);
    if (target != null) openTarget(target);
  }

  Future<void> stop() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    subscriptions.clear();
  }
}
