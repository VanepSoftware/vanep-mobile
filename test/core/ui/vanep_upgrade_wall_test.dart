import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
import 'package:vanep_mobile/core/ui/vanep_upgrade_wall.dart';

import 'localized_harness.dart';

class _FakeStore extends UpgraderStore {
  _FakeStore(this.storeVersion);

  final String storeVersion;

  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async => UpgraderVersionInfo(
    appStoreVersion: Version.parse(storeVersion),
    appStoreListingURL: 'https://play.google.com/store/apps/details?id=x',
    installedVersion: installedVersion,
  );
}

class _AndroidOS extends UpgraderOS {
  @override
  UpgraderOSType get currentOSType => UpgraderOSType.android;
}

Upgrader _upgrader({
  required String installed,
  required String store,
  String? minAppVersion,
}) {
  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'Vanep',
    packageName: 'com.vanep.vanep_mobile',
    version: installed,
    // A bigger build number must never matter, only the semantic version.
    buildNumber: '99',
    buildSignature: '',
  );
  return VanepUpgrader(
    minAppVersion: minAppVersion,
    storeController: UpgraderStoreController(
      onAndroid: () => _FakeStore(store),
    ),
    upgraderOS: _AndroidOS(),
  );
}

Future<void> _pump(WidgetTester tester, Upgrader upgrader) async {
  await tester.pumpWidget(
    localizedHarness(
      VanepUpgradeWall(upgrader: upgrader, child: const Text('app')),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('mandatory (installed < minAppVersion)', () {
    testWidgets('blocks the app, no way out', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.0', store: '1.0.1', minAppVersion: '1.0.1'),
      );

      expect(find.text('Atualização necessária'), findsOneWidget);
      expect(find.text('Atualizar agora'), findsOneWidget);
      expect(find.text('Depois'), findsNothing);
      expect(find.text('Ignorar'), findsNothing);
    });

    testWidgets('cannot be dismissed by tapping outside', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.0', store: '1.0.1', minAppVersion: '1.0.1'),
      );

      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();

      expect(find.text('Atualização necessária'), findsOneWidget);
    });

    testWidgets('cannot be dismissed with the back button', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.0', store: '1.0.1', minAppVersion: '1.0.1'),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Atualização necessária'), findsOneWidget);
    });
  });

  group('soft notice (installed >= minAppVersion, store newer)', () {
    testWidgets('a patch update does not block', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.0', store: '1.0.1', minAppVersion: '1.0.0'),
      );

      expect(find.text('Atualização disponível'), findsOneWidget);
      expect(find.text('Atualização necessária'), findsNothing);
      expect(find.text('Depois'), findsOneWidget);
    });

    testWidgets('no minAppVersion means never blocked', (tester) async {
      await _pump(tester, _upgrader(installed: '1.0.0', store: '1.0.1'));

      expect(find.text('Atualização disponível'), findsOneWidget);
      expect(find.text('Depois'), findsOneWidget);
    });

    testWidgets('"Depois" dismisses it', (tester) async {
      await _pump(tester, _upgrader(installed: '1.0.0', store: '1.0.1'));

      await tester.tap(find.text('Depois'));
      await tester.pumpAndSettle();

      expect(find.text('Atualização disponível'), findsNothing);
      expect(find.text('app'), findsOneWidget);
    });

    testWidgets('invalid minAppVersion never blocks', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.0', store: '1.0.1', minAppVersion: 'abc'),
      );

      expect(find.text('Atualização necessária'), findsNothing);
    });
  });

  group('no update', () {
    testWidgets('lets the app through when versions are equal', (tester) async {
      await _pump(
        tester,
        _upgrader(installed: '1.0.1', store: '1.0.1', minAppVersion: '1.0.1'),
      );

      expect(find.text('Atualização necessária'), findsNothing);
      expect(find.text('Atualização disponível'), findsNothing);
      expect(find.text('app'), findsOneWidget);
    });

    testWidgets('lets the app through when installed is newer', (tester) async {
      await _pump(tester, _upgrader(installed: '1.1.0', store: '1.0.1'));

      expect(find.text('Atualização disponível'), findsNothing);
      expect(find.text('Atualização necessária'), findsNothing);
    });
  });
}
