import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.token,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String token;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  AppNotification markedRead(DateTime at) => AppNotification(
    token: token,
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: readAt ?? at,
  );

  @override
  List<Object?> get props => [token, title, body, createdAt, readAt];
}

class NotificationPage extends Equatable {
  const NotificationPage({required this.items, required this.isLast});

  final List<AppNotification> items;
  final bool isLast;

  @override
  List<Object?> get props => [items, isLast];
}
