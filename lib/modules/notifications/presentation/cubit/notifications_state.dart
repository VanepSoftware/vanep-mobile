import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';

enum NotificationsStatus { loading, loaded, loadFailed }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.items = const [],
    this.nextPage = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;

  bool get hasUnread => items.any((item) => item.isUnread);

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, items, nextPage, hasMore, isLoadingMore];
}
