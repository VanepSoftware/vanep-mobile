import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/domain/failures/notification_failure.dart';

abstract class NotificationRepository {
  Future<Result<NotificationFailure, NotificationPage>> listMine({
    required int page,
    required int size,
  });

  Future<Result<NotificationFailure, void>> markRead(String token);

  Future<Result<NotificationFailure, void>> markAllRead();
}
