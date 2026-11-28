import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<NotificationPage> fetchMine({
    required int page,
    required int size,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.notificationsEndpoint,
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return notificationPageFromJson(response.data ?? const {});
  }

  Future<void> markRead(String token) {
    return dio.post<void>(environment.notificationReadEndpoint(token));
  }

  Future<void> markAllRead() {
    return dio.post<void>(environment.notificationsReadAllEndpoint);
  }
}

NotificationPage notificationPageFromJson(Map<String, dynamic> json) {
  final content = json['content'];
  final items = content is List
      ? content
            .whereType<Map<String, dynamic>>()
            .map(appNotificationFromJson)
            .whereType<AppNotification>()
            .toList()
      : const <AppNotification>[];
  return NotificationPage(items: items, isLast: json['last'] != false);
}

AppNotification? appNotificationFromJson(Map<String, dynamic> json) {
  final token = json['token'];
  final createdAt = DateTime.tryParse('${json['createdAt']}');
  if (token is! String || createdAt == null) return null;
  final readAt = json['readAt'];
  return AppNotification(
    token: token,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    createdAt: createdAt.toLocal(),
    readAt: readAt is String ? DateTime.tryParse(readAt)?.toLocal() : null,
  );
}
