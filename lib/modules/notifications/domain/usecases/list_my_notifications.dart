import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/domain/failures/notification_failure.dart';
import 'package:vanep_mobile/modules/notifications/domain/repositories/notification_repository.dart';

class ListMyNotifications {
  const ListMyNotifications(this.repository);

  static const pageSize = 20;

  final NotificationRepository repository;

  Future<Result<NotificationFailure, NotificationPage>> call({int page = 0}) {
    return repository.listMine(page: page, size: pageSize);
  }
}
