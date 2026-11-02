import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_van_selector_sheet.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/assistant_shell.dart';

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
  });

  testWidgets('starts on Rota tab and bottom bar has Rota, Alunos, Perfil', (
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

    expect(find.text('Rota do dia'), findsOneWidget);

    final nav = tester.widget<VanepBottomNav>(find.byType(VanepBottomNav));
    expect([for (final i in nav.items) i.label], equals(['Rota', 'Alunos', 'Meu perfil']));
  });

  testWidgets('switching tabs updates active coming soon view', (tester) async {
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

    expect(find.text('Alunos'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Meu perfil'));
    await tester.pump();

    expect(find.text('Meu perfil'), findsNWidgets(2));
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

  testWidgets('shows active van details without switch button when only 1 van exists', (
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

    expect(find.text('Renault Master • ABC-1234'), findsOneWidget);
    expect(find.text('Van ativa • Manhã'), findsOneWidget);
    expect(find.text('Trocar van'), findsNothing);
  });

  testWidgets('shows switch van button when linked to multiple vans and opens selector', (
    tester,
  ) async {
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
