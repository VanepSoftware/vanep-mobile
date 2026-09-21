import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/client/presentation/pages/client_home_tab.dart';

import '../../../core/ui/localized_harness.dart';

Widget clientHomeHarness({
  VoidCallback? onMenuTapped,
  VoidCallback? onNotificationsTapped,
  VoidCallback? onFindVanTapped,
}) {
  return localizedHarness(
    Scaffold(
      body: ClientHomeTab(
        displayName: 'Maria Silva',
        onMenuTapped: onMenuTapped ?? () {},
        onNotificationsTapped: onNotificationsTapped ?? () {},
        onFindVanTapped: onFindVanTapped ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('greets the user and shows the no linked van state', (
    tester,
  ) async {
    await tester.pumpWidget(clientHomeHarness());

    expect(find.text('Olá, Maria!'), findsOneWidget);
    expect(find.text('Nenhuma van vinculada'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('find a van calls its callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(clientHomeHarness(onFindVanTapped: () => taps++));

    await tester.tap(find.text('Procurar van'));

    expect(taps, 1);
  });

  testWidgets('the top bar menu and bell call their callbacks', (tester) async {
    var menuTaps = 0;
    var notificationTaps = 0;
    await tester.pumpWidget(
      clientHomeHarness(
        onMenuTapped: () => menuTaps++,
        onNotificationsTapped: () => notificationTaps++,
      ),
    );

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.tap(find.byTooltip('Notificações'));

    expect(menuTaps, 1);
    expect(notificationTaps, 1);
  });
}
