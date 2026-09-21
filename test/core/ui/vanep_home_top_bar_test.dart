import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_home_top_bar.dart';

import 'localized_harness.dart';

void main() {
  testWidgets('menu and notifications buttons call their callbacks', (
    tester,
  ) async {
    var menuTaps = 0;
    var notificationTaps = 0;
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: VanepHomeTopBar(
            onMenuTapped: () => menuTaps++,
            onNotificationsTapped: () => notificationTaps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.tap(find.byTooltip('Notificações'));

    expect(menuTaps, 1);
    expect(notificationTaps, 1);
  });

  testWidgets('icons sit on the content edges with full tap targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: VanepHomeTopBar(
              onMenuTapped: () {},
              onNotificationsTapped: () {},
            ),
          ),
        ),
      ),
    );

    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getTopLeft(find.byIcon(Icons.menu_rounded)).dx, 20);
    expect(
      tester.getTopRight(find.byIcon(Icons.notifications_outlined)).dx,
      screenWidth - 20,
    );
    expect(
      tester.getSize(find.byTooltip('Abrir menu')).width,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );
  });
}
