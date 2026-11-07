import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';

import 'localized_harness.dart';

const nbsp = '\u00a0';

void main() {
  Future<void> pumpPrice(WidgetTester tester, int installments) {
    return tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: VanepInstallmentPrice(
            amountCents: 65000,
            installments: installments,
            amountStyle: const TextStyle(fontSize: 18),
            countStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the monthly installment with the count after it', (
    tester,
  ) async {
    await pumpPrice(tester, 12);

    expect(
      find.text('R\$${nbsp}650/mês · 12x', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a single payment is paid upfront', (tester) async {
    await pumpPrice(tester, 1);

    expect(
      find.text('R\$${nbsp}650\u00a0à vista', findRichText: true),
      findsOneWidget,
    );
  });
}
