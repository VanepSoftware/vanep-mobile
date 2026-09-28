import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/postal_address_display.dart';
import 'package:vanep_mobile/core/ui/vanep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';

import 'localized_host.dart';

const summary = PostalAddressDisplayFields(
  street: 'QND 12, 10',
  cityState: 'Brasília/DF',
  neighborhood: 'Taguatinga',
  zipCode: '72120-120',
);

class CardEvents {
  var register = 0;
  var edit = 0;
  var clear = 0;
}

Widget card(
  CardEvents events, {
  PostalAddressDisplayFields? fields,
  String? errorText,
}) {
  return localizedHost(
    VanepAddressCard(
      title: 'Endereço',
      emptyLabel: 'Nenhum endereço.',
      registerLabel: 'Cadastrar endereço',
      menuTooltip: 'Mais opções',
      editLabel: 'Editar endereço',
      clearLabel: 'Limpar endereço',
      summary: fields,
      errorText: errorText,
      onRegister: () => events.register++,
      onEdit: () => events.edit++,
      onClear: () => events.clear++,
    ),
  );
}

void main() {
  testWidgets('without an address it shows the empty text and the register '
      'action', (tester) async {
    final events = CardEvents();
    await tester.pumpWidget(card(events));

    expect(find.text('Endereço'), findsOneWidget);
    expect(find.text('Nenhum endereço.'), findsOneWidget);
    expect(find.byType(PopupMenuButton<VanepAddressCardAction>), findsNothing);

    await tester.tap(find.text('Cadastrar endereço'));
    expect(events.register, 1);
  });

  testWidgets('with an address it shows the summary and no register action', (
    tester,
  ) async {
    await tester.pumpWidget(card(CardEvents(), fields: summary));

    expect(find.text('QND 12, 10'), findsOneWidget);
    expect(find.text('Taguatinga · Brasília/DF · 72120-120'), findsOneWidget);
    expect(find.text('Cadastrar endereço'), findsNothing);
    expect(find.text('Nenhum endereço.'), findsNothing);
  });

  testWidgets('the menu edits and clears', (tester) async {
    final events = CardEvents();
    await tester.pumpWidget(card(events, fields: summary));

    await tester.tap(find.byType(PopupMenuButton<VanepAddressCardAction>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar endereço'));
    await tester.pumpAndSettle();
    expect(events.edit, 1);

    await tester.tap(find.byType(PopupMenuButton<VanepAddressCardAction>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpar endereço'));
    await tester.pumpAndSettle();
    expect(events.clear, 1);
  });

  testWidgets('the menu carries its tooltip', (tester) async {
    await tester.pumpWidget(card(CardEvents(), fields: summary));

    expect(find.byTooltip('Mais opções'), findsOneWidget);
  });

  testWidgets('shows an error below the content', (tester) async {
    await tester.pumpWidget(
      card(CardEvents(), fields: summary, errorText: 'Cidade não encontrada.'),
    );

    expect(find.text('Cidade não encontrada.'), findsOneWidget);
  });

  testWidgets('has no error text by default and sits in an outlined panel', (
    tester,
  ) async {
    await tester.pumpWidget(card(CardEvents(), fields: summary));

    expect(find.text('Cidade não encontrada.'), findsNothing);
    expect(find.byType(VanepOutlinedPanel), findsOneWidget);
  });
}
