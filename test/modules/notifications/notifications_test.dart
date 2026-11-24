import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/domain/failures/notification_failure.dart';
import 'package:vanep_mobile/modules/notifications/domain/usecases/list_my_notifications.dart';
import 'package:vanep_mobile/modules/notifications/domain/usecases/mark_notification_read.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_state.dart';

class MockListMyNotifications extends Mock implements ListMyNotifications {}

class MockMarkNotificationRead extends Mock implements MarkNotificationRead {}

class MockMarkAllNotificationsRead extends Mock
    implements MarkAllNotificationsRead {}

final now = DateTime(2026, 11, 23, 10);
final unread = AppNotification(
  token: 'n1',
  title: 'Nova proposta',
  body: 'Você recebeu uma proposta',
  createdAt: DateTime(2026, 11, 22),
);
final read = AppNotification(
  token: 'n2',
  title: 'Lida',
  body: '',
  createdAt: DateTime(2026, 11, 21),
  readAt: DateTime(2026, 11, 21, 12),
);

void main() {
  group('notificationPageFromJson', () {
    test('maps the Spring page and skips malformed items', () {
      final page = notificationPageFromJson({
        'content': [
          {
            'token': 'abc',
            'title': 'T',
            'body': 'B',
            'createdAt': '2026-11-22T10:00:00Z',
            'readAt': null,
          },
          {'title': 'sem token'},
        ],
        'last': false,
      });

      expect(page.items, hasLength(1));
      expect(page.items.single.token, 'abc');
      expect(page.items.single.isUnread, isTrue);
      expect(page.isLast, isFalse);
    });
  });

  group('NotificationsCubit', () {
    late MockListMyNotifications list;
    late MockMarkNotificationRead markRead;
    late MockMarkAllNotificationsRead markAll;

    setUp(() {
      list = MockListMyNotifications();
      markRead = MockMarkNotificationRead();
      markAll = MockMarkAllNotificationsRead();
    });

    NotificationsCubit build() => NotificationsCubit(
      listMyNotifications: list,
      markNotificationRead: markRead,
      markAllNotificationsRead: markAll,
      clock: () => now,
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'load emits loaded with the first page',
      setUp: () => when(() => list(page: any(named: 'page'))).thenAnswer(
        (_) async => Ok(NotificationPage(items: [unread, read], isLast: false)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const NotificationsState(),
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [unread, read],
          nextPage: 1,
          hasMore: true,
        ),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'load emits loadFailed on error',
      setUp: () =>
          when(() => list(page: any(named: 'page')))
              .thenAnswer((_) async => const Err(NotificationFailure.network)),
      build: build,
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [
        const NotificationsState(status: NotificationsStatus.loadFailed),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'loadMore appends the next page',
      setUp: () => when(() => list(page: 1)).thenAnswer(
        (_) async => Ok(NotificationPage(items: [read], isLast: true)),
      ),
      build: build,
      seed: () => NotificationsState(
        status: NotificationsStatus.loaded,
        items: [unread],
        nextPage: 1,
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      skip: 1,
      expect: () => [
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [unread, read],
          nextPage: 2,
        ),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markRead updates optimistically and rolls back on failure',
      setUp: () => when(() => markRead('n1'))
          .thenAnswer((_) async => const Err(NotificationFailure.unexpected)),
      build: build,
      seed: () => NotificationsState(
        status: NotificationsStatus.loaded,
        items: [unread],
      ),
      act: (cubit) => cubit.markRead('n1'),
      expect: () => [
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [unread.markedRead(now)],
        ),
        NotificationsState(status: NotificationsStatus.loaded, items: [unread]),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markAllRead marks every item as read',
      setUp: () =>
          when(() => markAll()).thenAnswer((_) async => const Ok(null)),
      build: build,
      seed: () => NotificationsState(
        status: NotificationsStatus.loaded,
        items: [unread, read],
      ),
      act: (cubit) => cubit.markAllRead(),
      expect: () => [
        NotificationsState(
          status: NotificationsStatus.loaded,
          items: [unread.markedRead(now), read],
        ),
      ],
      verify: (_) => verify(() => markAll()).called(1),
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markRead ignores items already read',
      build: build,
      seed: () =>
          NotificationsState(status: NotificationsStatus.loaded, items: [read]),
      act: (cubit) => cubit.markRead('n2'),
      expect: () => const <NotificationsState>[],
      verify: (_) => verifyNever(() => markRead(any())),
    );
  });
}
