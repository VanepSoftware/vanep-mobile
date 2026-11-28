import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/notifications/domain/usecases/list_my_notifications.dart';
import 'package:vanep_mobile/modules/notifications/domain/usecases/mark_notification_read.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.listMyNotifications,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const NotificationsState());

  final ListMyNotifications listMyNotifications;
  final MarkNotificationRead markNotificationRead;
  final MarkAllNotificationsRead markAllNotificationsRead;
  final DateTime Function() _clock;

  Future<void> load() async {
    emit(const NotificationsState());
    await refresh();
  }

  Future<void> refresh() async {
    final result = await listMyNotifications();
    if (isClosed) return;
    emit(
      result.fold(
        (_) => state.copyWith(status: NotificationsStatus.loadFailed),
        (page) => NotificationsState(
          status: NotificationsStatus.loaded,
          items: page.items,
          nextPage: 1,
          hasMore: !page.isLast,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final result = await listMyNotifications(page: state.nextPage);
    if (isClosed) return;
    emit(
      result.fold(
        (_) => state.copyWith(isLoadingMore: false),
        (page) => state.copyWith(
          items: [...state.items, ...page.items],
          nextPage: state.nextPage + 1,
          hasMore: !page.isLast,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> markRead(String token) async {
    final index = state.items.indexWhere((item) => item.token == token);
    if (index < 0 || !state.items[index].isUnread) return;
    final previous = state.items;
    final updated = [...previous];
    updated[index] = previous[index].markedRead(_clock());
    emit(state.copyWith(items: updated));

    final result = await markNotificationRead(token);
    if (isClosed || result.isOk) return;
    emit(state.copyWith(items: previous));
  }

  Future<void> markAllRead() async {
    if (!state.hasUnread) return;
    final previous = state.items;
    final now = _clock();
    emit(
      state.copyWith(
        items: [for (final item in previous) item.markedRead(now)],
      ),
    );

    final result = await markAllNotificationsRead();
    if (isClosed || result.isOk) return;
    emit(state.copyWith(items: previous));
  }
}
