import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/guards/assistant_route_guard.dart';

void main() {
  group('AssistantRouteGuard', () {
    test('isRestricted identifies driver and client restricted routes', () {
      expect(AssistantRouteGuard.isRestricted('/driver'), isTrue);
      expect(AssistantRouteGuard.isRestricted('/proposals'), isTrue);
      expect(AssistantRouteGuard.isRestricted('/documents'), isTrue);
      expect(AssistantRouteGuard.isRestricted('/search'), isTrue);
      expect(AssistantRouteGuard.isRestricted('/client'), isTrue);
      expect(AssistantRouteGuard.isRestricted('/assistant'), isFalse);
      expect(AssistantRouteGuard.isRestricted('/home'), isFalse);
      expect(AssistantRouteGuard.isRestricted(null), isFalse);
    });

    testWidgets('intercepts restricted route when user is assistant', (
      tester,
    ) async {
      var unauthorizedCalled = false;
      final guard = AssistantRouteGuard(
        isAssistant: () => true,
        onUnauthorized: (_) => unauthorizedCalled = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [guard],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/proposals'),
                child: const Text('Go to proposals'),
              ),
            ),
          ),
          routes: {
            '/proposals': (context) => const Scaffold(
                  body: Text('Proposals Screen'),
                ),
          },
        ),
      );

      await tester.tap(find.text('Go to proposals'));
      await tester.pumpAndSettle();

      expect(unauthorizedCalled, isTrue);
      expect(find.text('Proposals Screen'), findsNothing);
      expect(find.text('Go to proposals'), findsOneWidget);
    });

    testWidgets('allows navigation when user is not assistant', (
      tester,
    ) async {
      var unauthorizedCalled = false;
      final guard = AssistantRouteGuard(
        isAssistant: () => false,
        onUnauthorized: (_) => unauthorizedCalled = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [guard],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/proposals'),
                child: const Text('Go to proposals'),
              ),
            ),
          ),
          routes: {
            '/proposals': (context) => const Scaffold(
                  body: Text('Proposals Screen'),
                ),
          },
        ),
      );

      await tester.tap(find.text('Go to proposals'));
      await tester.pumpAndSettle();

      expect(unauthorizedCalled, isFalse);
      expect(find.text('Proposals Screen'), findsOneWidget);
    });
  });
}
