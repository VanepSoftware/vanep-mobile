import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/session/session_lifecycle_observer.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/firebase_push_messaging_gateway.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/flutter_local_notification_display.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/push_background_handler.dart';
import 'package:vanep_mobile/modules/push_notifications/data/datasources/push_device_remote_datasource.dart';
import 'package:vanep_mobile/modules/push_notifications/data/repositories/push_device_repository_impl.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/repositories/push_device_repository.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/usecases/push_device_session.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/usecases/push_message_router.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_device_platform.dart';
import 'package:vanep_mobile/modules/push_notifications/presentation/cubit/push_navigation_cubit.dart';

void registerPushNavigationDependencies(GetIt getIt) {
  getIt.registerSingleton<PushNavigationCubit>(PushNavigationCubit());
}

/// Needs Firebase initialized and the authenticated Dio registered.
Future<void> startPushNotifications(
  GetIt getIt, {
  required ReportPushError reportError,
}) async {
  FirebaseMessaging.onBackgroundMessage(showBackgroundPushMessage);
  final gateway = FirebasePushMessagingGateway(
    messaging: FirebaseMessaging.instance,
    reportError: reportError,
  );
  final display = FlutterLocalNotificationDisplay(
    plugin: FlutterLocalNotificationsPlugin(),
    channel: buildPushNotificationChannel(resolveDeviceLocalizations()),
  );
  await display.initialize();

  getIt
    ..registerSingleton<PushDeviceRepository>(
      PushDeviceRepositoryImpl(
        remote: PushDeviceRemoteDataSource(
          dio: getIt<Dio>(instanceName: authenticatedDioName),
          environment: getIt<Environment>(),
        ),
      ),
    )
    ..registerSingleton<SessionLifecycleObserver>(
      PushDeviceSession(
        gateway: gateway,
        repository: getIt<PushDeviceRepository>(),
        platform: PushDevicePlatform.android,
      ),
    )
    ..registerSingleton<PushMessageRouter>(
      PushMessageRouter(
        gateway: gateway,
        display: display,
        openTarget: getIt<PushNavigationCubit>().openTarget,
      ),
    );
  await getIt<PushMessageRouter>().start();
}
