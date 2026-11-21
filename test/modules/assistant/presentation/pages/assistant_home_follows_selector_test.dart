import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_home_scenario.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_route_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_home_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_today_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/mark_present_in_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/undo_stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';

import '../../mocks/assistant_mocks.dart';

DateTime afternoon() => DateTime(2026, 10, 14, 16);

void main() {
  late AssistantVanSelectorCubit selector;

  setUp(() {
    final repository = AssistantRouteRepositoryImpl(
      dataSource: MockedAssistantRouteDataSource(
        scenario: AssistantHomeScenario.onRouteBoarding,
        clock: afternoon,
      ),
    );
    getIt.registerFactory<AssistantHomeCubit>(
      () => AssistantHomeCubit(
        findHomeOverview: FindAssistantHomeOverview(repository),
        findTodayRoute: FindAssistantTodayRoute(repository),
        confirmStopPassengers: ConfirmStopPassengers(repository),
        undoStopConfirmation: UndoStopConfirmation(repository),
        markPresentInVan: MarkPresentInVan(repository),
        respondToInvite: RespondToAssistantInvite(MockAssistantRepository()),
        clock: afternoon,
      ),
    );
    final getLinkedVans = MockGetLinkedVans();
    when(() => getLinkedVans())
        .thenAnswer((_) async => const Ok([mockedVanCarlos, mockedVanRita]));
    selector = AssistantVanSelectorCubit(getLinkedVans: getLinkedVans);
    addTearDown(getIt.reset);
  });

  Widget harness() => MaterialApp(
    theme: VanepTheme.light(),
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AssistantVanSelectorCubit>.value(
      value: selector,
      child: Builder(
        builder: (context) => AssistantHomeTab.withCubit(
          displayName: 'Marcos',
          vanSelector: context.read<AssistantVanSelectorCubit>(),
        ),
      ),
    ),
  );

  testWidgets(
    'shows the van chosen in the shell selector, not its own default',
    (tester) async {
      await tester.pumpWidget(harness());
      await selector.loadVans();
      await tester.pumpAndSettle();

      expect(find.text('Embarque em casa'), findsOneWidget);
      expect(find.text('Carlos · manhã'), findsNothing);
    },
  );

  testWidgets('switching van in the selector switches the home', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await selector.loadVans();
    await tester.pumpAndSettle();

    selector.selectVan(mockedVanRita);
    await tester.pumpAndSettle();

    expect(find.text('Sem rota hoje'), findsOneWidget);
  });
}
