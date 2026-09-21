import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';

import 'localized_host.dart';

Widget select({
  Gender? value,
  ValueChanged<Gender?>? onChanged,
  bool enabled = true,
}) {
  return localizedHost(
    VanepGenderSelect(
      label: 'Gênero',
      value: value,
      onChanged: onChanged ?? (_) {},
      enabled: enabled,
    ),
  );
}

void main() {
  testWidgets('shows the label above the field', (tester) async {
    await tester.pumpWidget(select(value: Gender.female));

    expect(find.text('Gênero'), findsOneWidget);
    expect(find.text('Feminino'), findsOneWidget);
  });

  testWidgets('an omitted gender shows Prefiro não informar selected', (
    tester,
  ) async {
    await tester.pumpWidget(select());

    expect(find.text('Prefiro não informar'), findsOneWidget);
    expect(find.text('—'), findsNothing);
  });

  testWidgets('opens with the four options', (tester) async {
    await tester.pumpWidget(select(value: Gender.female));

    await tester.tap(find.byType(DropdownButton<Gender?>));
    await tester.pumpAndSettle();

    expect(find.text('Masculino'), findsOneWidget);
    expect(find.text('Feminino'), findsWidgets);
    expect(find.text('Outro'), findsOneWidget);
    expect(find.text('Prefiro não informar'), findsOneWidget);
  });

  testWidgets('choosing a gender reports it', (tester) async {
    Gender? chosen;
    var calls = 0;
    await tester.pumpWidget(
      select(
        onChanged: (gender) {
          chosen = gender;
          calls++;
        },
      ),
    );

    await tester.tap(find.byType(DropdownButton<Gender?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masculino').last);
    await tester.pumpAndSettle();

    expect(chosen, Gender.male);
    expect(calls, 1);
  });

  testWidgets('choosing Prefiro não informar reports null', (tester) async {
    Gender? chosen = Gender.female;
    await tester.pumpWidget(
      select(value: Gender.female, onChanged: (gender) => chosen = gender),
    );

    await tester.tap(find.byType(DropdownButton<Gender?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prefiro não informar').last);
    await tester.pumpAndSettle();

    expect(chosen, isNull);
  });

  testWidgets('a disabled select does not open', (tester) async {
    await tester.pumpWidget(select(value: Gender.female, enabled: false));

    await tester.tap(find.byType(DropdownButton<Gender?>), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Masculino'), findsNothing);
  });

  testWidgets('a disabled select keeps the value legible under the app theme', (
    tester,
  ) async {
    await tester.pumpWidget(select(value: Gender.female, enabled: false));

    final context = tester.element(find.text('Feminino'));
    final style = DefaultTextStyle.of(context).style;
    expect(style.color, VanepColors.textMuted);
  });
}
