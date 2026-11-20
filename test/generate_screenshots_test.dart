import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/pages/driver_search_page.dart';

class MockDriverSearchCubit extends Mock implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const sampleDrivers = [
  DriverSearchResult(
    token: 'd1',
    name: 'Fabio Teixeira',
    rating: 4.9,
    basePrice: 380,
    experienceYears: 12,
    available: true,
    serviceAreas: ['Asa Sul', 'Asa Norte', 'Sudoeste'],
  ),
  DriverSearchResult(
    token: 'd2',
    name: 'Carlos Alberto Silva',
    rating: 4.8,
    basePrice: 350,
    experienceYears: 8,
    available: true,
    serviceAreas: ['Taguatinga Norte', 'Águas Claras'],
  ),
  DriverSearchResult(
    token: 'd3',
    name: 'Mariana Medeiros',
    rating: 5.0,
    basePrice: 420,
    experienceYears: 15,
    available: true,
    serviceAreas: ['Lago Sul', 'Jardim Botânico'],
  ),
];

Future<void> loadAppFonts() async {
  // MaterialIcons
  final materialIconsFile = File(
    '/home/caio-lucas/fvm/versions/3.47.2/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (materialIconsFile.existsSync()) {
    final materialLoader = FontLoader('MaterialIcons');
    materialLoader.addFont(
      Future.value(ByteData.view(materialIconsFile.readAsBytesSync().buffer)),
    );
    await materialLoader.load();
  }

  // Roboto
  final robotoFile = File(
    '/home/caio-lucas/fvm/versions/3.47.2/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  );
  final robotoBoldFile = File(
    '/home/caio-lucas/fvm/versions/3.47.2/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf',
  );
  final robotoMediumFile = File(
    '/home/caio-lucas/fvm/versions/3.47.2/bin/cache/artifacts/material_fonts/Roboto-Medium.ttf',
  );

  for (final family in ['Roboto', '.SF Pro Text', '.SF Pro Display', 'sans-serif']) {
    final loader = FontLoader(family);
    if (robotoFile.existsSync()) {
      loader.addFont(
        Future.value(ByteData.view(robotoFile.readAsBytesSync().buffer)),
      );
    }
    if (robotoBoldFile.existsSync()) {
      loader.addFont(
        Future.value(ByteData.view(robotoBoldFile.readAsBytesSync().buffer)),
      );
    }
    if (robotoMediumFile.existsSync()) {
      loader.addFont(
        Future.value(ByteData.view(robotoMediumFile.readAsBytesSync().buffer)),
      );
    }
    await loader.load();
  }
}

Widget buildScreenshotApp({
  required GlobalKey key,
  required DriverSearchCubit cubit,
  required PlaceAutocompleteController autocomplete,
}) {
  final baseTheme = VanepTheme.light();
  final themeWithFont = baseTheme.copyWith(
    textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto'),
  );

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: themeWithFont,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: RepaintBoundary(
      key: key,
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
        child: BlocProvider<DriverSearchCubit>.value(
          value: cubit,
          child: DriverSearchPage(
            autocomplete: autocomplete,
            onDriverSelected: (_) {},
            onQuoteRequested: (_) {},
          ),
        ),
      ),
    ),
  );
}

Future<void> capturePng(WidgetTester tester, GlobalKey key, String path) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    File(path).writeAsBytesSync(buffer);
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('Generate Find Van Screenshots', (tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final datasource = MockPlaceAutocompleteDataSource();
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([]));
    final autocomplete = PlaceAutocompleteController(datasource: datasource);
    addTearDown(() => autocomplete.dispose());

    final outputDir =
        '/home/caio-lucas/OpenBot/Agents/agent-ebf428e8-3963-4ee3-bd51-afa6caae68af/screenshots';

    // 1. Recommended Vans Screenshot
    {
      final key = GlobalKey();
      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        const DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: sampleDrivers,
          isShowingRecommended: true,
        ),
      );
      when(() => cubit.stream).thenAnswer(
        (_) => const Stream<DriverSearchState>.empty(),
      );

      await tester.pumpWidget(
        buildScreenshotApp(
          key: key,
          cubit: cubit,
          autocomplete: autocomplete,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await capturePng(tester, key, '$outputDir/1_find_van_recommended.png');
    }

    // 2. Search Results Screenshot
    {
      final key = GlobalKey();
      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        const DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: sampleDrivers,
          placeId: 'place-cmb',
          searchedLabel: 'Colégio Militar de Brasília',
        ),
      );
      when(() => cubit.stream).thenAnswer(
        (_) => const Stream<DriverSearchState>.empty(),
      );

      await tester.pumpWidget(
        buildScreenshotApp(
          key: key,
          cubit: cubit,
          autocomplete: autocomplete,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await capturePng(tester, key, '$outputDir/2_find_van_search_results.png');
    }

    // 3. Empty State Screenshot
    {
      final key = GlobalKey();
      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        const DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: [],
          placeId: 'place-empty',
          searchedLabel: 'Zona Rural Leste',
        ),
      );
      when(() => cubit.stream).thenAnswer(
        (_) => const Stream<DriverSearchState>.empty(),
      );

      await tester.pumpWidget(
        buildScreenshotApp(
          key: key,
          cubit: cubit,
          autocomplete: autocomplete,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await capturePng(tester, key, '$outputDir/3_find_van_empty_state.png');
    }
  });
}