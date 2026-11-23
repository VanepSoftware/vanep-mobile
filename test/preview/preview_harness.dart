import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const previewPhoneSize = Size(390, 844);

const previewPixelRatio = 2.0;

final isPreviewRun = Platform.environment['VANEP_PREVIEW'] == '1';

final String? previewSkip = isPreviewRun
    ? null
    : 'Run with `make preview` to render screens.';

String flutterSdkRoot() {
  final fromEnvironment = Platform.environment['FLUTTER_ROOT'];
  if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
    return fromEnvironment;
  }
  final executable = Platform.resolvedExecutable.replaceAll(r'\', '/');
  return executable.substring(0, executable.indexOf('/bin/cache/'));
}

Future<void> loadFontFamily(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> loadPreviewFonts() async {
  final fonts = '${flutterSdkRoot()}/bin/cache/artifacts/material_fonts';
  final roboto = [
    for (final weight in ['Regular', 'Medium', 'Bold', 'Black', 'Light'])
      '$fonts/Roboto-$weight.ttf',
  ];
  await loadFontFamily('Roboto', roboto);
  await loadFontFamily('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
}

void setPreviewViewport(WidgetTester tester, {double height = 844}) {
  tester.view.physicalSize =
      Size(previewPhoneSize.width, height) * previewPixelRatio;
  tester.view.devicePixelRatio = previewPixelRatio;
  addTearDown(tester.view.reset);
}

ButtonStyle? withRobotoLabel(ButtonStyle? style) {
  final textStyle = style?.textStyle;
  return style?.copyWith(
    textStyle: WidgetStateProperty.resolveWith(
      (states) =>
          (textStyle?.resolve(states) ?? const TextStyle()).copyWith(
            fontFamily: 'Roboto',
          ),
    ),
  );
}

// Button labels have no font family, so a device draws them with the system
// Roboto while the test engine draws blocks. Only the family changes here.
ThemeData previewTheme() {
  final theme = VanepTheme.light();
  return theme.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: withRobotoLabel(theme.filledButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: withRobotoLabel(theme.textButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: withRobotoLabel(theme.outlinedButtonTheme.style),
    ),
  );
}

Widget previewApp(Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: previewTheme(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: home,
  );
}

Future<void> expectPreview(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../preview/$name.png'),
  );
}
