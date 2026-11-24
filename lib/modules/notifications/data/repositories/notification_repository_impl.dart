import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/domain/failures/notification_failure.dart';
import 'package:vanep_mobile/modules/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required this.remote});

  final NotificationRemoteDataSource remote;

  @override
  Future<Result<NotificationFailure, NotificationPage>> listMine({
    required int page,
    required int size,
  }) => _guard(() => remote.fetchMine(page: page, size: size));

  @override
  Future<Result<NotificationFailure, void>> markRead(String token) =>
      _guard(() => remote.markRead(token));

  @override
  Future<Result<NotificationFailure, void>> markAllRead() =>
      _guard(remote.markAllRead);

  Future<Result<NotificationFailure, T>> _guard<T>(
    Future<T> Function() call,
  ) async {
    try {
      return Ok(await call());
    } on DioException catch (error) {
      return Err(notificationFailureFrom(error));
    }
  }
}

NotificationFailure notificationFailureFrom(DioException error) {
  return error.response == null
      ? NotificationFailure.network
      : NotificationFailure.unexpected;
}
