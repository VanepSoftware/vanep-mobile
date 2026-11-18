import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_van_detail_page.dart';

import '../../../auth/presentation/auth_test_harness.dart';
import '../../fixtures/client_vans_fixtures.dart';

void main() {
  testWidgets('displays all detailed vehicle, driver, contract and dependent information', (
    tester,
  ) async {
    var chatTapped = false;
    await tester.pumpWidget(
      authTestApp(
        ClientVanDetailPage(
          van: testClientVan,
          onChatWithDriver: () => chatTapped = true,
        ),
      ),
    );

    // 1. Vehicle info
    expect(find.text('Mercedes-Benz Sprinter 415 CDI'), findsWidgets);
    expect(find.text('ABC-4E21'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    expect(find.text('Branca'), findsOneWidget);
    expect(find.text('15 lugares'), findsOneWidget);

    // 2. Driver info
    expect(find.text('Carlos Alberto Silva'), findsOneWidget);
    expect(find.text('(11) 98765-4321'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);

    // Chat with driver button (in driver section)
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VanepPrimaryButton));
    expect(chatTapped, isTrue);

    // Scroll to view contract section
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // 3. Contract info
    expect(find.textContaining('350'), findsOneWidget);
    expect(find.text('Vencimento todo dia 5'), findsOneWidget);
    expect(find.text('12 parcelas'), findsOneWidget);
    expect(find.textContaining('4.200'), findsOneWidget);

    // Scroll further to view dependents section
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // 4. Dependent info
    expect(find.text('Lucas Silva'), findsOneWidget);
    expect(find.text('Colégio Santo Agostinho'), findsOneWidget);
    expect(find.text('Rua das Flores, 123 - Jardins'), findsOneWidget);
    expect(find.text('Manhã'), findsOneWidget);
    expect(find.text('Seg'), findsOneWidget);
  });
}
