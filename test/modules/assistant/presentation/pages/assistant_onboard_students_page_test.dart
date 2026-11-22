import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_swipe_to_confirm.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_onboard_students_page.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

Widget localizedApp(Widget home) {
  return MaterialApp(
    theme: VanepTheme.light(),
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  late MockAssistantHomeCubit cubit;
  final onPickup = AssistantHomeState(
    status: AssistantHomeLoadStatus.ready,
    overview: testHomeOverviewTwoVans,
    selectedVanToken: testAssistantVanPrimary.token,
    route: testRouteOnPickup(),
  );

  setUp(() {
    cubit = MockAssistantHomeCubit();
    when(() => cubit.state).thenReturn(onPickup);
    whenListen(
      cubit,
      const Stream<AssistantHomeState>.empty(),
      initialState: onPickup,
    );
    when(() => cubit.correctNoShow(any())).thenAnswer((_) async {});
  });

  Widget onboardPage() => localizedApp(
    BlocProvider<AssistantHomeCubit>.value(
      value: cubit,
      child: const AssistantOnboardStudentsPage(),
    ),
  );

  testWidgets('groups the students and sums them up', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(onboardPage());

    expect(find.text('3 a bordo'), findsOneWidget);
    expect(find.text('3 aguardando'), findsOneWidget);
    expect(find.text('1 não embarcou'), findsOneWidget);
    expect(find.text('A bordo'), findsOneWidget);
    expect(find.text('Aguardando embarque'), findsOneWidget);
    expect(find.text('Não embarcou'), findsOneWidget);
  });

  testWidgets('who waits at the current stop reads "Agora"', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(onboardPage());

    expect(find.text('Agora'), findsNWidgets(2));
  });

  testWidgets('a no-show shows why it happened', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(onboardPage());

    expect(find.textContaining('não estava no ponto'), findsOneWidget);
  });

  testWidgets('"Corrigir" confirms the boarding by swipe', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(onboardPage());
    await tester.tap(find.text('Corrigir'));
    await tester.pumpAndSettle();
    expect(find.text('Laura embarcou depois?'), findsOneWidget);

    await tester.drag(
      find.byKey(vanepSwipeToConfirmKnobKey),
      const Offset(1000, 0),
    );
    await tester.pumpAndSettle();

    verify(() => cubit.correctNoShow('passenger-laura')).called(1);
  });

  testWidgets('the home row opens this page', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      localizedApp(
        BlocProvider<AssistantHomeCubit>.value(
          value: cubit,
          child: const AssistantHomeTab(displayName: 'Marcos'),
        ),
      ),
    );
    await tester.tap(find.text('Alunos a bordo'));
    await tester.pumpAndSettle();

    expect(find.byType(AssistantOnboardStudentsPage), findsOneWidget);
  });
}
