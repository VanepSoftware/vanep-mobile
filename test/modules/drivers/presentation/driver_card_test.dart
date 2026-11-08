import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_card.dart';

import '../drivers_fixtures.dart';

Widget _harness(Driver driver, {VoidCallback? onTap}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(
      body: DriverCard(driver: driver, onTap: onTap),
    ),
  );
}

void main() {
  testWidgets('shows name, experience, rating and city', (tester) async {
    await tester.pumpWidget(_harness(testDriverDto));

    expect(find.text('Carlos Souza'), findsOneWidget);
    expect(find.text('8 anos'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Taguatinga'), findsOneWidget);
  });

  testWidgets('hides the rating star when there is no rating', (tester) async {
    await tester.pumpWidget(_harness(testDriverDtoNoRating));

    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text('Ceilândia'), findsOneWidget);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _harness(testDriverDto, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(DriverCard));
    expect(tapped, isTrue);
  });

  testWidgets('offers to request a quote with the base price', (tester) async {
    var requested = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: DriverCard(
            driver: testDriverDto,
            basePriceCents: 32000,
            onQuoteRequested: () => requested = true,
          ),
        ),
      ),
    );

    expect(find.text('a partir de R\$\u00a0320'), findsOneWidget);
    expect(find.textContaining('x de'), findsNothing);

    await tester.tap(find.text('Pedir orçamento'));
    expect(requested, isTrue);
  });

  testWidgets('without a quote action there is no quote button', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(testDriverDto));

    expect(find.text('Pedir orçamento'), findsNothing);
  });
}
