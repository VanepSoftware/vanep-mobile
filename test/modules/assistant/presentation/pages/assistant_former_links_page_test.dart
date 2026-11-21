import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_former_links.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_former_links_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_former_links_page.dart';

Widget localizedApp(Widget body) {
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
    home: Scaffold(body: body),
  );
}

final now = DateTime(2026, 10, 14, 7);
DateTime fixedClock() => now;

void main() {
  group('former links (VAN-68)', () {
    test('the repository returns the mocked former links', () async {
      final repository = AssistantVansRepositoryImpl(
        dataSource: const MockedAssistantVansDataSource(clock: fixedClock),
      );

      final result = await repository.findFormerLinks();

      expect(result.valueOrNull, hasLength(1));
    });

    blocTest<AssistantFormerLinksCubit, AssistantFormerLinksState>(
      'loads the former links',
      build: () => AssistantFormerLinksCubit(
        findFormerLinks: FindAssistantFormerLinks(
          AssistantVansRepositoryImpl(
            dataSource: const MockedAssistantVansDataSource(clock: fixedClock),
          ),
        ),
      ),
      act: (cubit) => cubit.loadFormerLinks(),
      verify: (cubit) {
        expect(cubit.state.status, AssistantFormerLinksStatus.ready);
        expect(cubit.state.links.single.van.driverName, 'Renata Alves');
      },
    );

    testWidgets('the page shows the van and the period', (tester) async {
      final links = await const MockedAssistantVansDataSource(clock: fixedClock)
          .findFormerLinks();
      await tester.pumpWidget(
        localizedApp(AssistantFormerLinksBody(links: links)),
      );

      expect(find.text('Renata · Master JKL3M45'), findsOneWidget);
      expect(find.textContaining('03/02/2026 – 31/07/2026'), findsOneWidget);
    });

    testWidgets('without former links says so', (tester) async {
      await tester.pumpWidget(
        localizedApp(const AssistantFormerLinksBody(links: [])),
      );

      expect(find.text('Nenhum vínculo anterior.'), findsOneWidget);
    });
  });
}
