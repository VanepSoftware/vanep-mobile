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
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_adjustment_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_detail_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/quote_request_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_decline_sheet.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_dto.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/pages/driver_search_page.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_profile_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_ratings_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_van_photos_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_verification_sheet.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/shell/client_bottom_nav.dart';
import 'package:vanep_mobile/shell/client_shell.dart';

import 'modules/client_proposals/client_proposals_fixtures.dart';
import 'modules/client_proposals/client_proposals_mocks.dart';
import 'modules/conversations/conversations_fixtures.dart';
import 'modules/conversations/conversations_mocks.dart';
import 'modules/drivers/presentation/drivers_presentation_mocks.dart';
import 'modules/negotiations/negotiations_fixtures.dart';

class MockDriverSearchCubit extends Mock implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const sampleDrivers = [
  DriverSearchResult(
    token: 'd1',
    name: 'Carlos Souza',
    rating: 4.9,
    ratingCount: 32,
    basePrice: 320,
    experienceYears: 8,
    available: true,
    serviceAreas: ['Asa Sul', 'Taguatinga'],
  ),
  DriverSearchResult(
    token: 'd2',
    name: 'João Pedro Lima',
    rating: 4.7,
    ratingCount: 18,
    basePrice: 300,
    experienceYears: 5,
    available: true,
    serviceAreas: ['Taguatinga Norte', 'Águas Claras'],
  ),
  DriverSearchResult(
    token: 'd3',
    name: 'Rita Alves',
    basePrice: 340,
    experienceYears: 3,
    available: true,
    serviceAreas: ['QNL 5', 'Taguatinga'],
  ),
];

const sampleCarlosProfile = DriverProfileDto(
  token: 'd1',
  name: 'Carlos Souza',
  phone: '61999990000',
  rating: 4.9,
  ratingCount: 32,
  bio: 'Transporte escolar com pontualidade, ar-condicionado e monitora.',
  experienceYears: 8,
  basePrice: 320,
  available: true,
  workStartTime: '06:00',
  workEndTime: '18:30',
  workDays: 'Seg a sex',
  waitToleranceMinutes: 5,
  serviceAreas: ['QNL 5', 'Taguatinga', 'Asa Sul'],
  vehicles: [
    DriverProfileVehicleDto(
      token: 'v1',
      brand: 'Mercedes-Benz',
      model: 'Sprinter',
      manufactureYear: 2021,
      color: 'Branca',
      capacity: 16,
      hasAssistant: true,
    ),
  ],
  shiftVacancies: [
    DriverShiftVacancyDto(shift: 'Manhã', spots: 3),
    DriverShiftVacancyDto(shift: 'Tarde', spots: 1),
    DriverShiftVacancyDto(shift: 'Noite', spots: 0),
  ],
  ratingBreakdown: [
    DriverRatingBreakdownDto(stars: 5, count: 27),
    DriverRatingBreakdownDto(stars: 4, count: 4),
    DriverRatingBreakdownDto(stars: 3, count: 1),
    DriverRatingBreakdownDto(stars: 2, count: 0),
    DriverRatingBreakdownDto(stars: 1, count: 0),
  ],
  ratings: [
    DriverProfileRatingDto(
      authorName: 'Patrícia S.',
      dateLabel: 'há 2 semanas',
      stars: 5,
      comment: 'Muito pontual e cuidadoso com as crianças no embarque.',
    ),
    DriverProfileRatingDto(
      authorName: 'Roberto M.',
      dateLabel: 'há 1 mês',
      stars: 5,
      comment: 'Van sempre limpa e comunicação rápida com os pais.',
    ),
  ],
);

const sampleAddress = PersonalAddress(
  token: 'addr-1',
  street: 'QNL 5 Conjunto F',
  neighborhood: 'QNL 5',
  cityName: 'Taguatinga',
  cityToken: 'city-1',
  stateUf: 'DF',
  countryIsoCode: 'BR',
);

final sampleDependents = [
  DependentDto(
    token: 'dep-1',
    name: 'Ana Oliveira',
    birthDate: '${DateTime.now().year - 8}-01-10',
    isDefault: true,
    address: const DependentAddressDto(
      token: 'dep-addr-1',
      street: 'QNL 5 Conjunto F',
      neighborhood: 'QNL 5',
      cityName: 'Taguatinga',
      stateUf: 'DF',
    ),
    school: const DependentSchoolDto(
      token: 'sch-1',
      name: 'Colégio Horizonte',
    ),
  ),
  DependentDto(
    token: 'dep-2',
    name: 'Pedro Oliveira',
    birthDate: '${DateTime.now().year - 11}-01-10',
  ),
];

String? resolveMaterialFontsDir() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    final candidate = Directory(
      '$flutterRoot/bin/cache/artifacts/material_fonts',
    );
    if (candidate.existsSync()) return candidate.path;
  }

  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    final candidate = Directory('${dir.path}/bin/cache/artifacts/material_fonts');
    if (candidate.existsSync()) return candidate.path;
    final directCandidate = Directory('${dir.path}/material_fonts');
    if (directCandidate.existsSync()) return directCandidate.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

Future<void> loadAppFonts() async {
  final fontDir = resolveMaterialFontsDir();
  if (fontDir == null) return;

  final materialIconsFile = File('$fontDir/MaterialIcons-Regular.otf');
  if (materialIconsFile.existsSync()) {
    final materialLoader = FontLoader('MaterialIcons');
    materialLoader.addFont(
      Future.value(ByteData.view(materialIconsFile.readAsBytesSync().buffer)),
    );
    await materialLoader.load();
  }

  final robotoFiles = [
    File('$fontDir/Roboto-Regular.ttf'),
    File('$fontDir/Roboto-Medium.ttf'),
    File('$fontDir/Roboto-Bold.ttf'),
    File('$fontDir/Roboto-Light.ttf'),
    File('$fontDir/Roboto-Black.ttf'),
  ];

  for (final family in [
    'Roboto',
    '.SF Pro Text',
    '.SF Pro Display',
    'sans-serif',
  ]) {
    final loader = FontLoader(family);
    for (final file in robotoFiles) {
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.view(file.readAsBytesSync().buffer)),
        );
      }
    }
    await loader.load();
  }
}

ThemeData buildScreenshotTheme() {
  final baseTheme = VanepTheme.light();
  const robotoFallback = TextStyle(fontFamily: 'Roboto');

  return baseTheme.copyWith(
    textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: baseTheme.appBarTheme.copyWith(
      titleTextStyle: robotoFallback.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: baseTheme.colorScheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: baseTheme.filledButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          robotoFallback.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: baseTheme.textButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          robotoFallback.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: baseTheme.outlinedButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          robotoFallback.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

Widget wrapScreenshotApp({
  required GlobalKey key,
  required Widget child,
}) {
  return RepaintBoundary(
    key: key,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildScreenshotTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      builder: (context, navigator) => DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
        child: navigator ?? const SizedBox.shrink(),
      ),
      home: child,
    ),
  );
}

Widget buildScreenshotApp({
  required GlobalKey key,
  required DriverSearchCubit cubit,
  required PlaceAutocompleteController autocomplete,
  bool withBottomNav = true,
}) {
  return wrapScreenshotApp(
    key: key,
    child: BlocProvider<DriverSearchCubit>.value(
      value: cubit,
      child: withBottomNav
          ? Scaffold(
              body: DriverSearchPage(
                autocomplete: autocomplete,
                onDriverSelected: (_) {},
                onQuoteRequested: (_) {},
                onInviteSubmitted: (_) {},
              ),
              bottomNavigationBar: ClientBottomNav(
                currentIndex: clientShellVansTabIndex,
                onDestinationSelected: (_) {},
              ),
            )
          : DriverSearchPage(
              autocomplete: autocomplete,
              onDriverSelected: (_) {},
              onQuoteRequested: (_) {},
              onInviteSubmitted: (_) {},
            ),
    ),
  );
}

Future<void> capturePng(WidgetTester tester, GlobalKey key, String path) async {
  final file = File(path);
  if (!file.parent.existsSync()) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    file.writeAsBytesSync(buffer);
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  testWidgets('Generate Find Van Prototype & Flow Screenshots', (tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 920 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final datasource = MockPlaceAutocompleteDataSource();
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([]));
    final autocomplete = PlaceAutocompleteController(datasource: datasource);
    addTearDown(() => autocomplete.dispose());

    final outputDir = Platform.environment['VANEP_SCREENSHOTS_DIR'];
    Future<void> saveScreenshot(GlobalKey key, String fileName) async {
      if (outputDir == null || outputDir.isEmpty) return;
      await capturePng(tester, key, '$outputDir/$fileName');
    }

    // 1. Main Find Van Prototype Screen
    {
      final key = GlobalKey();
      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: sampleDrivers,
          personalAddress: sampleAddress,
          dependents: sampleDependents,
          selectedDependentTokens: const {'dep-1', 'dep-2'},
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
      await saveScreenshot(key, '1_find_van_recommended.png');
    }

    // 2. Empty State Screenshot
    {
      final key = GlobalKey();
      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: const [],
          personalAddress: sampleAddress,
          dependents: sampleDependents,
          selectedDependentTokens: const {'dep-1'},
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
          withBottomNav: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '3_find_van_empty_state.png');
    }

    // 3. Driver Profile Screen (opened by "Perfil")
    {
      final key = GlobalKey();
      final profileCubit = MockDriverProfileCubit();
      when(() => profileCubit.state).thenReturn(
        const DriverProfileState(
          status: DriverProfileStatus.loaded,
          profile: sampleCarlosProfile,
        ),
      );
      when(() => profileCubit.stream).thenAnswer(
        (_) => const Stream<DriverProfileState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: BlocProvider<DriverProfileCubit>.value(
            value: profileCubit,
            child: DriverProfilePage(onQuoteRequested: (_) {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '4_driver_profile.png');
    }

    // 4. Quote Request Screen (opened by "Pedir orçamento")
    {
      final key = GlobalKey();
      final today = DateTime(2026, 11, 22);
      final week = SchoolWeek.fromDays([
        for (final day in weekdaysMondayToFriday)
          SchoolDay(weekday: day, shift: SchoolShift.morning),
      ]);
      final draft = ServiceRequestDraft(
        driverToken: sampleCarlosProfile.token,
        desiredStartDate: today,
        items: [
          RequestDraftItem(
            dependentToken: sampleDependents.first.token,
            legsByDay: {
              for (final day in weekdaysMondayToFriday)
                day: {RouteLeg.outbound, RouteLeg.homebound},
            },
          ),
        ],
      );
      final quoteCubit = MockQuoteRequestCubit();
      when(() => quoteCubit.state).thenReturn(
        QuoteRequestState(
          status: QuoteRequestStatus.ready,
          setup: QuoteRequestSetup(
            driver: sampleCarlosProfile,
            students: QuoteStudents(
              students: [
                QuoteStudent(dependent: sampleDependents.first, week: week),
              ],
            ),
            openRequests: const [],
          ),
          draft: draft,
          today: today,
        ),
      );
      when(() => quoteCubit.stream).thenAnswer(
        (_) => const Stream<QuoteRequestState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: BlocProvider<QuoteRequestCubit>.value(
            value: quoteCubit,
            child: QuoteRequestPage(
              actions: QuoteRequestActions(
                onCompleteStudent: (_, _) async {},
                onCompleteClientField: (_) async {},
                onSent: (_) {},
                onOpenNegotiation: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '5_quote_request.png');
    }

    // 5. Quote Chat Flow Screen (opened after sending quote request)
    {
      final key = GlobalKey();
      final now = DateTime.utc(2026, 11, 22, 14, 15);
      final request = TestClientServiceRequest(
        token: 'req-1',
        conversationToken: 'conv-1',
        driverToken: 'd1',
        driverName: 'Carlos Souza',
        driverRating: 4.9,
        items: [
          testItemFor(
            sampleDependents.first,
            schoolName: 'Colégio Horizonte',
            shift: SchoolShift.morning,
          ),
        ],
        desiredStartDate: DateTime(2027, 2, 1),
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      final chatCubit = MockChatCubit();
      when(() => chatCubit.state).thenReturn(
        ChatState(
          status: ChatStatus.ready,
          messages: [
            TestConversationMessage(
              token: 'm1',
              sender: ConversationParticipant.driver,
              body: 'Oi! Atendo o Colégio Horizonte pela manhã e tenho vaga.',
              sentAt: now.subtract(const Duration(minutes: 2)),
            ),
          ],
        ),
      );
      when(() => chatCubit.stream).thenAnswer(
        (_) => const Stream<ChatState>.empty(),
      );

      final timelineCubit = MockNegotiationTimelineCubit();
      when(() => timelineCubit.state).thenReturn(
        NegotiationTimelineState<ClientServiceRequest>(
          status: NegotiationTimelineStatus.ready,
          negotiation: ConversationNegotiation<ClientServiceRequest>(
            request: request,
            versions: const [],
          ),
        ),
      );
      when(() => timelineCubit.stream).thenAnswer(
        (_) => const Stream<NegotiationTimelineState<ClientServiceRequest>>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ChatCubit>.value(value: chatCubit),
              BlocProvider<NegotiationTimelineCubit<ClientServiceRequest>>.value(
                value: timelineCubit,
              ),
            ],
            child: ChatPage<ClientServiceRequest>(
              counterpartName: 'Carlos Souza',
              viewerSide: ConversationParticipant.client,
              counterpartRoleCaption: 'Motorista',
              onViewDriverProfile: () {},
              clock: () => now,
              negotiationActions: NegotiationChatActions(
                onSeeProposal: (_) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '6_quote_chat_flow.png');
    }
  });

  testWidgets('Generate Updated Subscreens and Proposals Screenshots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 920 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final outputDir = Platform.environment['VANEP_SCREENSHOTS_DIR'];
    Future<void> saveScreenshot(GlobalKey key, String fileName) async {
      if (outputDir == null || outputDir.isEmpty) return;
      await capturePng(tester, key, '$outputDir/$fileName');
    }

    // 4a. Van Photos Screen
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: const DriverVanPhotosPage(profile: sampleCarlosProfile),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '4a_driver_van_photos.png');
    }

    // 4b. Driver Ratings Screen
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: const DriverRatingsPage(profile: sampleCarlosProfile),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '4b_driver_ratings.png');
    }

    // 4c. Driver Verification Bottom Sheet
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: Scaffold(
            backgroundColor: Colors.black26,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const DriverVerificationSheet(
                  driverName: 'Carlos Souza',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '4c_driver_verification.png');
    }

    // 2. Find Van Filters Bottom Sheet
    {
      final key = GlobalKey();
      final datasource = MockPlaceAutocompleteDataSource();
      when(() => datasource.findSuggestions(any(), any()))
          .thenAnswer((_) async => const Ok([]));
      final autocomplete = PlaceAutocompleteController(datasource: datasource);
      addTearDown(autocomplete.dispose);

      final cubit = MockDriverSearchCubit();
      when(() => cubit.state).thenReturn(
        DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: sampleDrivers,
          personalAddress: sampleAddress,
          dependents: sampleDependents,
          selectedDependentTokens: const {'dep-1'},
          isShowingRecommended: true,
        ),
      );
      when(() => cubit.stream).thenAnswer(
        (_) => const Stream<DriverSearchState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: BlocProvider<DriverSearchCubit>.value(
            value: cubit,
            child: DriverSearchPage(
              autocomplete: autocomplete,
              onDriverSelected: (_) {},
              onQuoteRequested: (_) {},
              onInviteSubmitted: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await saveScreenshot(key, '2_find_van_filters.png');
    }

    // 7. Proposal Detail Page
    {
      final key = GlobalKey();
      final detailCubit = MockProposalDetailCubit();
      when(() => detailCubit.state).thenReturn(
        ProposalDetailState(
          status: ProposalDetailStatus.ready,
          proposalToken: testVersion2.token,
          request: testProposalForSiblings,
          proposal: testVersion2,
          versions: [testVersion1, testVersion2],
        ),
      );
      when(() => detailCubit.stream).thenAnswer(
        (_) => const Stream<ProposalDetailState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: BlocProvider<ProposalDetailCubit>.value(
            value: detailCubit,
            child: ProposalDetailPage(
              clock: () => testProposalsNow,
              actions: ProposalDetailActions(
                onChat: (_) {},
                onAskAdjustment: (_, _) async => false,
                onDecline: (_, _) async => null,
                onAccepted: (_, _) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '7_proposal_detail.png');
    }

    // 8. Proposal Adjustment Page
    {
      final key = GlobalKey();
      final adjustmentCubit = MockProposalAdjustmentCubit();
      when(() => adjustmentCubit.state).thenReturn(
        const ProposalAdjustmentState(),
      );
      when(() => adjustmentCubit.stream).thenAnswer(
        (_) => const Stream<ProposalAdjustmentState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: BlocProvider<ProposalAdjustmentCubit>.value(
            value: adjustmentCubit,
            child: ProposalAdjustmentPage(
              request: testProposalForSiblings,
              proposal: testVersion2,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '8_proposal_adjustment.png');
    }

    // 9. Proposal Decline Sheet
    {
      final key = GlobalKey();
      final declineCubit = MockProposalDeclineCubit();
      when(() => declineCubit.state).thenReturn(
        const ProposalDeclineState(),
      );
      when(() => declineCubit.stream).thenAnswer(
        (_) => const Stream<ProposalDeclineState>.empty(),
      );

      await tester.pumpWidget(
        wrapScreenshotApp(
          key: key,
          child: Scaffold(
            backgroundColor: Colors.black26,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BlocProvider<ProposalDeclineCubit>.value(
                  value: declineCubit,
                  child: ProposalDeclineSheet(
                    request: testProposalForSiblings,
                    proposal: testVersion2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await saveScreenshot(key, '9_proposal_decline.png');
    }
  });
}
