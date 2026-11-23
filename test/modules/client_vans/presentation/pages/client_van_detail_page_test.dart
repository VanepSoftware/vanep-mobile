import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_van_detail_page.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_hero_card.dart';

import '../../fixtures/client_vans_fixtures.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: VanepTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: child,
    );
  }

  testWidgets(
    'displays prototype hero card, grouped sections, and interactive sheets',
    (tester) async {
      var chatTapped = false;
      await tester.pumpWidget(
        wrap(
          ClientVanDetailPage(
            van: testClientVan,
            onChatWithDriver: () => chatTapped = true,
          ),
        ),
      );

      expect(find.byType(ClientVanHeroCard), findsOneWidget);
      expect(find.text('Contrato ativo'), findsOneWidget);
      expect(find.text('Mercedes-Benz Sprinter 415 CDI'), findsWidgets);
      expect(find.text('ABC-4E21'), findsOneWidget);
      expect(find.text('Carlos Alberto Silva'), findsOneWidget);
      expect(find.text('4,9'), findsOneWidget);

      await tester.tap(find.byTooltip('Conversar com motorista'));
      await tester.pump();
      expect(chatTapped, isTrue);

      await tester.tap(find.byTooltip('Ligar para Carlos Alberto Silva'));
      await tester.pumpAndSettle();
      expect(find.text('Telefone do motorista'), findsOneWidget);
      expect(find.text('(11) 98765-4321'), findsOneWidget);
      await tester.tap(find.text('Copiar número'));
      await tester.pumpAndSettle();

      expect(find.text('Na van'), findsOneWidget);
      expect(find.text('Lucas Silva'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Horários e paradas'));
      await tester.pumpAndSettle();
      expect(find.text('Colégio Santo Agostinho'), findsWidgets);
      expect(find.text('Rua das Flores, 123 - Jardins'), findsOneWidget);
      expect(find.text('Ida: 06:40 · Volta: 12:10'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contrato'));
      await tester.pumpAndSettle();
      expect(find.text('Vencimento todo dia 5'), findsWidgets);
      expect(find.text('12 parcelas'), findsOneWidget);
      expect(find.textContaining('4.200'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Segurança'), findsOneWidget);
      expect(find.text('Cancelar contrato'), findsOneWidget);

      await tester.tap(find.text('Documentos do motorista e da van'));
      await tester.pumpAndSettle();
      expect(find.text('Branca'), findsOneWidget);
      expect(find.text('15 lugares'), findsOneWidget);
      final sheetBox = tester.getRect(find.byType(SingleChildScrollView).last);
      expect(tester.getTopLeft(find.text('Cor')).dx, sheetBox.left + 20.0);
      expect(tester.getTopRight(find.text('Branca')).dx, sheetBox.right - 20.0);
      expect(tester.getTopRight(find.text('2022')).dx, sheetBox.right - 20.0);
      expect(
        tester.getTopRight(find.text('15 lugares')).dx,
        sheetBox.right - 20.0,
      );
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Avisar falta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Avisar falta'));
      await tester.pumpAndSettle();
      expect(find.text('Em breve'), findsOneWidget);
    },
  );

  testWidgets('forwards onDependentTapped when tapping a dependent on the van', (
    tester,
  ) async {
    ClientVanDependent? tappedDependent;
    await tester.pumpWidget(
      wrap(
        ClientVanDetailPage(
          van: testClientVan,
          onDependentTapped: (dep) => tappedDependent = dep,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Lucas Silva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucas Silva'));
    await tester.pump();

    expect(tappedDependent, testClientVan.dependents.first);
  });

  testWidgets('handles pending van without dependents or contract gracefully', (
    tester,
  ) async {
    const emptyVan = ClientVan(
      token: 'link-empty',
      status: 'PENDING',
      driver: ClientVanDriver(
        token: 'drv-empty',
        name: 'Gustavo Santos',
      ),
      vehicle: ClientVanVehicle(
        token: 'veh-empty',
        brand: 'Fiat',
        model: 'Ducato',
        manufactureYear: 2023,
        color: 'Branca',
        capacity: 15,
      ),
    );

    await tester.pumpWidget(wrap(const ClientVanDetailPage(van: emptyVan)));

    expect(find.text('Contrato pendente'), findsOneWidget);
    expect(
      find.text('Nenhum dependente vinculado a esta van ainda.'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Contrato pendente de ativação'), findsOneWidget);
  });

  testWidgets('translates SchoolShift values into localized labels', (
    tester,
  ) async {
    const apiVan = ClientVan(
      token: 'link-api',
      status: 'ACTIVE',
      driver: ClientVanDriver(token: 'drv-api', name: 'Fabio Teixeira'),
      vehicle: ClientVanVehicle(
        token: 'veh-api',
        brand: 'Mercedes-Benz',
        model: 'Sprinter 415',
        manufactureYear: 2021,
        color: 'Branca',
        capacity: 15,
      ),
      dependents: [
        ClientVanDependent(
          token: 'dep-api',
          name: 'Lucas Souza',
          schoolName: 'Escola Municipal Seed',
          pickupAddress: 'Rua das Acácias, 250',
          shift: SchoolShift.afternoon,
          pickupTime: '06:40:00',
          returnTime: '12:10:00',
        ),
      ],
    );

    await tester.pumpWidget(wrap(const ClientVanDetailPage(van: apiVan)));

    expect(find.textContaining('Tarde'), findsOneWidget);
    expect(find.textContaining('AFTERNOON'), findsNothing);

    await tester.ensureVisible(find.text('Horários e paradas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horários e paradas'));
    await tester.pumpAndSettle();

    expect(find.text('Tarde'), findsOneWidget);
    expect(find.textContaining('AFTERNOON'), findsNothing);
  });

  testWidgets('omits vehicle banner and missing contract or shift fields', (
    tester,
  ) async {
    const partialVan = ClientVan(
      token: 'link-partial',
      status: 'ACTIVE',
      driver: ClientVanDriver(token: 'drv-partial', name: 'Marcos Silva'),
      contract: ClientVanContract(
        token: 'ctr-partial',
        status: 'ACTIVE',
      ),
      dependents: [
        ClientVanDependent(
          token: 'dep-partial',
          name: 'Sofia Costa',
          schoolName: 'Colégio Central',
          pickupAddress: '',
        ),
      ],
    );

    await tester.pumpWidget(wrap(const ClientVanDetailPage(van: partialVan)));

    expect(find.text('Marcos Silva'), findsWidgets);
    expect(find.textContaining('Van Escolar'), findsNothing);
    expect(find.text('Manhã'), findsNothing);
    expect(find.textContaining('Vencimento todo dia'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Contrato'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Contrato'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contrato'));
    await tester.pumpAndSettle();

    expect(find.text('Mensalidade'), findsNothing);
    expect(find.text('Período de vigência'), findsNothing);
    expect(find.text('Parcelas contratadas'), findsNothing);
    expect(find.text('Valor total'), findsNothing);
  });
}
