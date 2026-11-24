import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vanep_mobile/modules/notifications/data/repositories/notification_repository_impl.dart';
import 'package:vanep_mobile/modules/notifications/domain/repositories/notification_repository.dart';
import 'package:vanep_mobile/modules/notifications/domain/usecases/list_my_notifications.dart';
import 'package:vanep_mobile/modules/notifications/domain/usecases/mark_notification_read.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';

void registerNotificationsDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<NotificationRemoteDataSource>(
      NotificationRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
      ),
    )
    ..registerSingleton<NotificationRepository>(
      NotificationRepositoryImpl(remote: getIt<NotificationRemoteDataSource>()),
    )
    ..registerFactory<ListMyNotifications>(
      () => ListMyNotifications(getIt<NotificationRepository>()),
    )
    ..registerFactory<MarkNotificationRead>(
      () => MarkNotificationRead(getIt<NotificationRepository>()),
    )
    ..registerFactory<MarkAllNotificationsRead>(
      () => MarkAllNotificationsRead(getIt<NotificationRepository>()),
    )
    ..registerFactory<NotificationsCubit>(
      () => NotificationsCubit(
        listMyNotifications: getIt<ListMyNotifications>(),
        markNotificationRead: getIt<MarkNotificationRead>(),
        markAllNotificationsRead: getIt<MarkAllNotificationsRead>(),
      ),
    );
}
