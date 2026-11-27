import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_state.dart';
import 'package:vanep_mobile/modules/notifications/presentation/pages/notifications_page.dart';

import '../../core/ui/localized_harness.dart';
import 'notifications_doubles.dart';

final unreadNotification = AppNotification(
  token: 'n1',
  title: 'Nova proposta',
  body: 'Você recebeu uma proposta',
  createdAt: DateTime(2026, 11, 22),
);

void main() {
  late MockNotificationsCubit cubit;

  Future<void> pump(
    WidgetTester tester, {
    required List<AppNotification> items,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 800);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    cubit = MockNotificationsCubit();
    when(() => cubit.state).thenReturn(
      NotificationsState(status: NotificationsStatus.loaded, items: items),
    );
    when(cubit.markAllRead).thenAnswer((_) async {});
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<NotificationsCubit>.value(
          value: cubit,
          child: const NotificationsPage(),
        ),
      ),
    );
  }

  for (final textScale in [1.0, 1.3]) {
    testWidgets('title and action fit a narrow screen at scale $textScale', (
      tester,
    ) async {
      await pump(tester, items: [unreadNotification], textScale: textScale);

      final title = tester.renderObject<RenderParagraph>(
        find.text('Notificações'),
      );
      expect(
        title.size.width,
        greaterThanOrEqualTo(
          title.getMaxIntrinsicWidth(double.infinity).floorToDouble(),
        ),
      );
      final action = tester.getRect(find.byType(TextButton));
      expect(action.left, greaterThanOrEqualTo(0));
      expect(action.right, lessThanOrEqualTo(375));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the action marks everything as read', (tester) async {
    await pump(tester, items: [unreadNotification]);

    await tester.tap(find.text('Marcar todas como lidas'));

    verify(cubit.markAllRead).called(1);
  });

  testWidgets('there is no action without unread items', (tester) async {
    await pump(tester, items: const []);

    expect(find.text('Marcar todas como lidas'), findsNothing);
  });
}
