import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/notifications/domain/failures/notification_failure.dart';
import 'package:vanep_mobile/modules/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationRead {
  const MarkNotificationRead(this.repository);

  final NotificationRepository repository;

  Future<Result<NotificationFailure, void>> call(String token) {
    return repository.markRead(token);
  }
}

class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this.repository);

  final NotificationRepository repository;

  Future<Result<NotificationFailure, void>> call() {
    return repository.markAllRead();
  }
}
