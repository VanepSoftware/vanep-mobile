import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_students_page.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_vans_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_van_selector_sheet.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/assistant_shell.dart';

import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';

import '../modules/assistant/mocks/assistant_mocks.dart';
import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

class MockAssistantVanSelectorCubit extends MockCubit<AssistantVanSelectorState>
    implements AssistantVanSelectorCubit {}

const tVan1 = AssistantVan(
  token: 'van-1',
  driverToken: 'driver-1',
  driverName: 'Carlos Silva',
  plate: 'ABC-1234',
  model: 'Renault Master',
  shift: 'MORNING',
);

const tVan2 = AssistantVan(
  token: 'van-2',
  driverToken: 'driver-2',
  driverName: 'Maria Santos',
  plate: 'XYZ-5678',
  model: 'Mercedes Sprinter',
  shift: 'AFTERNOON',
);

Widget buildTestHarness({
  required AssistantVanSelectorCubit vanSelectorCubit,
  required AuthCubit authCubit,
  required ProfileSummaryCubit profileSummaryCubit,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<AssistantVanSelectorCubit>.value(value: vanSelectorCubit),
        BlocProvider<ProfileSummaryCubit>.value(value: profileSummaryCubit),
      ],
      child: const AssistantShell(
        profile: FakeUserProfile(
          name: 'Lucas Assistente',
          type: UserType.assistant,
        ),
      ),
    ),
  );
}

void main() {
  late MockAssistantVanSelectorCubit vanSelectorCubit;
  late MockAuthCubit authCubit;
  late MockProfileSummaryCubit profileSummaryCubit;

  setUp(() {
    vanSelectorCubit = MockAssistantVanSelectorCubit();
    authCubit = MockAuthCubit();
    profileSummaryCubit = MockProfileSummaryCubit();

    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    when(() => authCubit.refreshSessionProfile()).thenAnswer((_) async {});
    when(() => profileSummaryCubit.refresh(any())).thenAnswer((_) async {});
    registerFakeAssistantTabs(getIt);
    addTearDown(getIt.reset);
  });

  testWidgets('starts on Início and the bottom bar has Início, Vans, Alunos', (
    tester,
  ) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(
        vans: [tVan1],
        selectedVan: tVan1,
      ),
    );

    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );

    expect(find.byType(AssistantHomeTab), findsOneWidget);

    final nav = tester.widget<VanepBottomNav>(find.byType(VanepBottomNav));
    expect([
      for (final i in nav.items) i.label,
    ], equals(['Início', 'Vans', 'Alunos']));
  });

  testWidgets('switching tabs shows the vans and the students tabs', (
    tester,
  ) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(
        vans: [tVan1],
        selectedVan: tVan1,
      ),
    );

    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Alunos'));
    await tester.pump();

    expect(find.byType(AssistantStudentsPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pump();

    expect(find.byType(AssistantVansPage), findsOneWidget);
  });

  testWidgets('shows loading indicator when van selector is loading', (
    tester,
  ) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(isLoading: true),
    );

    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows no vans linked message when vans list is empty', (
    tester,
  ) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(vans: []),
    );

    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );

    expect(find.text('Nenhuma van vinculada no momento.'), findsOneWidget);
  });

  testWidgets(
    'shows selected van details without switch button when only 1 van exists',
    (tester) async {
      whenListen(
        vanSelectorCubit,
        const Stream<AssistantVanSelectorState>.empty(),
        initialState: const AssistantVanSelectorState(
          vans: [tVan1],
          selectedVan: tVan1,
        ),
      );

      await tester.pumpWidget(
        buildTestHarness(
          vanSelectorCubit: vanSelectorCubit,
          authCubit: authCubit,
          profileSummaryCubit: profileSummaryCubit,
        ),
      );

      expect(find.text('Renault Master • ABC-1234'), findsOneWidget);
      expect(find.text('Van selecionada • manhã'), findsOneWidget);
      expect(find.text('Trocar van'), findsNothing);
    },
  );

  testWidgets(
    'shows switch van button when linked to multiple vans and opens selector',
    (tester) async {
      whenListen(
        vanSelectorCubit,
        const Stream<AssistantVanSelectorState>.empty(),
        initialState: const AssistantVanSelectorState(
          vans: [tVan1, tVan2],
          selectedVan: tVan1,
        ),
      );

      await tester.pumpWidget(
        buildTestHarness(
          vanSelectorCubit: vanSelectorCubit,
          authCubit: authCubit,
          profileSummaryCubit: profileSummaryCubit,
        ),
      );

      expect(find.text('Renault Master • ABC-1234'), findsOneWidget);
      expect(find.text('Trocar van'), findsOneWidget);

      await tester.tap(find.text('Trocar van'));
      await tester.pumpAndSettle();

      expect(find.byType(AssistantVanSelectorSheet), findsOneWidget);
      expect(find.text('Mercedes Sprinter (XYZ-5678)'), findsOneWidget);
    },
  );

  testWidgets('shows load failure with retry instead of unlinked state', (
    tester,
  ) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(
        failure: AssistantFailure.network,
      ),
    );
    when(() => vanSelectorCubit.loadVans()).thenAnswer((_) async {});
    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );
    expect(find.text('Não foi possível carregar as vans.'), findsOneWidget);
    expect(find.text('Nenhuma van vinculada no momento.'), findsNothing);
    await tester.tap(find.text('Tentar novamente'));
    verify(() => vanSelectorCubit.loadVans()).called(1);
  });

  testWidgets('menu icon opens drawer', (tester) async {
    whenListen(
      vanSelectorCubit,
      const Stream<AssistantVanSelectorState>.empty(),
      initialState: const AssistantVanSelectorState(
        vans: [tVan1],
        selectedVan: tVan1,
      ),
    );

    await tester.pumpWidget(
      buildTestHarness(
        vanSelectorCubit: vanSelectorCubit,
        authCubit: authCubit,
        profileSummaryCubit: profileSummaryCubit,
      ),
    );

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Lucas Assistente'), findsOneWidget);
  });
}
