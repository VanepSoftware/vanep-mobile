import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_expiry_chip.dart';

void main() {
  final now = DateTime(2026, 10, 25, 10);

  test('up to two days left is urgent', () {
    expect(isExpiryUrgent(now, DateTime(2026, 10, 25, 23)), isTrue);
    expect(isExpiryUrgent(now, DateTime(2026, 10, 27, 8)), isTrue);
    expect(isExpiryUrgent(now, DateTime(2026, 10, 28, 8)), isFalse);
  });

  Future<VanepChip> pumpChip(
    WidgetTester tester, {
    required bool isUrgent,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VanepExpiryChip(label: 'Expira amanhã', isUrgent: isUrgent),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.schedule), findsOneWidget);
    return tester.widget<VanepChip>(find.byType(VanepChip));
  }

  testWidgets('a distant expiry is gray', (tester) async {
    final chip = await pumpChip(tester, isUrgent: false);

    expect(chip.background, VanepColors.avatarGraySurface);
    expect(chip.foreground, VanepColors.avatarGrayText);
  });

  testWidgets('an urgent expiry is amber', (tester) async {
    final chip = await pumpChip(tester, isUrgent: true);

    expect(chip.background, VanepColors.warningSurface);
    expect(chip.foreground, VanepColors.warningText);
  });
}
