import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_postal_address_form.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';

import '../domain/postal_address_draft_fixture.dart';
import 'localized_host.dart';

class FormEvents {
  final zip = <String>[];
  final street = <String>[];
  final number = <String>[];
  final complement = <String>[];
  final neighborhood = <String>[];
  final uf = <String>[];
  var cityTaps = 0;
}

Widget form(
  FormEvents events, {
  PostalAddressDraft draft = const PostalAddressDraft(),
  List<String> ufOptions = const ['DF', 'GO', 'SP'],
  bool showErrors = false,
  bool isLookingUpCep = false,
  String? zipErrorText,
  bool enabled = true,
}) {
  return localizedHost(
    VanepPostalAddressForm(
      draft: draft,
      ufOptions: ufOptions,
      showErrors: showErrors,
      isLookingUpCep: isLookingUpCep,
      zipErrorText: zipErrorText,
      enabled: enabled,
      onZipChanged: events.zip.add,
      onStreetChanged: events.street.add,
      onNumberChanged: events.number.add,
      onComplementChanged: events.complement.add,
      onNeighborhoodChanged: events.neighborhood.add,
      onUfChanged: events.uf.add,
      onCityTap: () => events.cityTaps++,
    ),
  );
}

Finder labelled(String label) => find.byWidgetPredicate(
  (widget) => widget is VanepTextField && widget.label == label,
);

TextField fieldLabelled(WidgetTester tester, String label) {
  return tester.widget<TextField>(
    find.descendant(of: labelled(label), matching: find.byType(TextField)),
  );
}

void expectNoLocation() {
  for (final label in ['CEP', 'Rua', 'Número', 'Complemento']) {
    expect(labelled(label), findsOneWidget, reason: label);
  }
  for (final label in ['Bairro', 'Município']) {
    expect(labelled(label), findsNothing, reason: label);
  }
  expect(find.byType(DropdownButton<String>), findsNothing);
  expect(find.byType(VanepCepAddressCard), findsNothing);
}

void main() {
  testWidgets('has no Places autocomplete', (tester) async {
    await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));

    expect(find.byType(VanepPlaceAutocompleteField), findsNothing);
  });

  group('waiting for the CEP', () {
    testWidgets(
      'a blank draft shows CEP, street, number and complement, no location',
      (tester) async {
        await tester.pumpWidget(form(FormEvents()));

        expectNoLocation();
      },
    );

    testWidgets(
      'an incomplete CEP hides the location the previous CEP had filled',
      (tester) async {
        final editing = fakeResolvedDraft().withZipCode('7212012');

        await tester.pumpWidget(form(FormEvents(), draft: editing));

        expectNoLocation();
      },
    );

    testWidgets(
      'while the lookup runs the CEP has a spinner and no location shows',
      (tester) async {
        await tester.pumpWidget(
          form(
            FormEvents(),
            draft: const PostalAddressDraft().withZipCode('72120120'),
            isLookingUpCep: true,
          ),
        );

        expectNoLocation();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(fieldLabelled(tester, 'CEP').enabled, isTrue);
      },
    );

    testWidgets('a new CEP over a resolved one hides the old city meanwhile', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(FormEvents(), draft: fakeResolvedDraft(), isLookingUpCep: true),
      );

      expectNoLocation();
    });

    testWidgets('street, number and complement are editable before the CEP', (
      tester,
    ) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events));

      for (final label in ['Rua', 'Número', 'Complemento']) {
        expect(fieldLabelled(tester, label).enabled, isTrue, reason: label);
      }
      await tester.enterText(
        find.descendant(of: labelled('Rua'), matching: find.byType(TextField)),
        'QND 12',
      );
      expect(events.street.last, 'QND 12');
    });

    testWidgets('marks only the CEP and the street as required', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents()));

      expect(find.text('*'), findsNWidgets(2));
    });

    testWidgets('no spinner once the lookup answered', (tester) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeResolvedDraft()));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('CEP that does not exist', () {
    testWidgets('shows no location, and the CEP with its message', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(
          FormEvents(),
          draft: fakeBlockedDraft(),
          zipErrorText: 'CEP não encontrado.',
        ),
      );

      expectNoLocation();
      expect(find.text('CEP não encontrado.'), findsOneWidget);
    });
  });

  group('resolved by the CEP', () {
    testWidgets('shows the summary card instead of UF and municipality', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeResolvedDraft()));

      expect(find.byType(VanepCepAddressCard), findsOneWidget);
      expect(find.text('Endereço do CEP'), findsNothing);
      expect(find.text('Brasília – DF'), findsOneWidget);
      expect(labelled('Município'), findsNothing);
      expect(find.byType(DropdownButton<String>), findsNothing);
    });

    testWidgets('the UF comes from the lookup even before the states load', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(
          FormEvents(),
          draft: fakeResolvedDraft(cityName: 'Goiânia', uf: 'GO'),
          ufOptions: const [],
        ),
      );

      expect(find.text('Goiânia – GO'), findsOneWidget);
    });

    testWidgets(
      'the neighborhood the CEP brought is in the card, not a field',
      (tester) async {
        await tester.pumpWidget(
          form(
            FormEvents(),
            draft: fakeResolvedDraft(neighborhood: 'Taguatinga'),
          ),
        );

        expect(find.text('Taguatinga, Brasília – DF'), findsOneWidget);
        expect(labelled('Bairro'), findsNothing);
      },
    );

    testWidgets('without a neighborhood from the CEP the field is editable', (
      tester,
    ) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events, draft: fakeResolvedDraft()));

      expect(labelled('Bairro'), findsOneWidget);
      expect(fieldLabelled(tester, 'Bairro').enabled, isTrue);

      await tester.enterText(
        find.descendant(
          of: labelled('Bairro'),
          matching: find.byType(TextField),
        ),
        'Taguatinga',
      );
      expect(events.neighborhood.last, 'Taguatinga');
    });

    testWidgets('street, number and complement stay editable', (tester) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events, draft: fakeResolvedDraft()));

      for (final label in ['Rua', 'Número', 'Complemento']) {
        expect(fieldLabelled(tester, label).enabled, isTrue, reason: label);
      }
      Future<void> type(String label, String text) => tester.enterText(
        find.descendant(of: labelled(label), matching: find.byType(TextField)),
        text,
      );
      await type('Rua', 'QND 13');
      await type('Número', '10');
      await type('Complemento', 'Casa 2');

      expect(events.street.last, 'QND 13');
      expect(events.number.last, '10');
      expect(events.complement.last, 'Casa 2');
    });

    testWidgets('the card sits between the CEP and the street', (tester) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeResolvedDraft()));

      final cep = tester.getTopLeft(labelled('CEP')).dy;
      final card = tester.getTopLeft(find.byType(VanepCepAddressCard)).dy;
      final street = tester.getTopLeft(labelled('Rua')).dy;
      expect(cep, lessThan(card));
      expect(card, lessThan(street));
    });

    testWidgets('shows the draft with the zip masked', (tester) async {
      await tester.pumpWidget(
        form(
          FormEvents(),
          draft: fakeResolvedDraft().withNumber('10').withComplement('Casa 2'),
        ),
      );

      expect(find.text('72120-120'), findsOneWidget);
      expect(find.text('QND 12'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Casa 2'), findsOneWidget);
    });

    testWidgets('marks CEP and street as required, and nothing else', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeResolvedDraft()));

      expect(find.text('*'), findsNWidgets(2));
    });
  });

  group('manual fallback', () {
    testWidgets('shows neighborhood, street, UF and municipality', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));

      for (final label in [
        'CEP',
        'Rua',
        'Número',
        'Complemento',
        'Bairro',
        'Município',
      ]) {
        expect(labelled(label), findsOneWidget, reason: label);
      }
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.byType(VanepCepAddressCard), findsNothing);
    });

    testWidgets('marks CEP, street, UF and municipality as required', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));

      expect(find.text('*'), findsNWidgets(4));
    });

    testWidgets('the location comes right under the CEP', (tester) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));

      final cep = tester.getTopLeft(labelled('CEP')).dy;
      final municipality = tester.getTopLeft(labelled('Município')).dy;
      final street = tester.getTopLeft(labelled('Rua')).dy;
      expect(cep, lessThan(municipality));
      expect(municipality, lessThan(street));
    });

    testWidgets('the UF list opens and reports the choice', (tester) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events, draft: fakeManualDraft()));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GO').last);
      await tester.pumpAndSettle();

      expect(events.uf, ['GO']);
    });

    testWidgets('a UF that the list does not carry is still shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(FormEvents(), draft: fakeManualDraft().withUf('RJ')),
      );

      expect(find.text('RJ'), findsOneWidget);
    });

    testWidgets('tapping the municipality opens the picker once a UF is set', (
      tester,
    ) async {
      final events = FormEvents();
      await tester.pumpWidget(
        form(events, draft: fakeManualDraft().withUf('DF')),
      );

      await tester.tap(find.text('Selecione a cidade'));
      await tester.pump();

      expect(events.cityTaps, 1);
    });

    testWidgets('without a UF the municipality asks for it first', (
      tester,
    ) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events, draft: fakeManualDraft()));

      expect(find.text('Selecione o estado primeiro'), findsOneWidget);
      await tester.tap(find.text('Selecione o estado primeiro'));
      await tester.pump();

      expect(events.cityTaps, 0);
    });

    testWidgets('a chosen municipality stays in manual mode', (tester) async {
      final draft = fakeManualDraft().withCity(
        token: 'city-goiania',
        name: 'Goiânia',
        uf: 'GO',
      );

      await tester.pumpWidget(form(FormEvents(), draft: draft));

      expect(find.byType(VanepCepAddressCard), findsNothing);
      expect(find.text('Goiânia'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('the neighborhood is editable', (tester) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));

      expect(fieldLabelled(tester, 'Bairro').enabled, isTrue);
    });
  });

  group('typing', () {
    testWidgets('a CEP is masked and reported as typed', (tester) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events));

      await tester.enterText(
        find.descendant(of: labelled('CEP'), matching: find.byType(TextField)),
        '70040010',
      );

      expect(events.zip.last, '70040-010');
      expect(find.text('70040-010'), findsOneWidget);
    });

    testWidgets('follows a new draft, for example after a CEP lookup', (
      tester,
    ) async {
      final events = FormEvents();
      await tester.pumpWidget(form(events));
      expectNoLocation();

      await tester.pumpWidget(
        form(events, draft: fakeResolvedDraft(neighborhood: 'Taguatinga')),
      );

      expect(find.text('QND 12'), findsOneWidget);
      expect(find.text('Taguatinga, Brasília – DF'), findsOneWidget);
    });

    testWidgets('a trailing space typed by the person is not eaten', (
      tester,
    ) async {
      final events = FormEvents();
      var draft = fakeManualDraft();
      late StateSetter update;
      await tester.pumpWidget(
        localizedHost(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return VanepPostalAddressForm(
                draft: draft,
                ufOptions: const ['DF'],
                onZipChanged: (_) {},
                onStreetChanged: (value) {
                  events.street.add(value);
                  update(() => draft = draft.withStreet(value));
                },
                onNumberChanged: (_) {},
                onComplementChanged: (_) {},
                onNeighborhoodChanged: (_) {},
                onUfChanged: (_) {},
                onCityTap: () {},
              );
            },
          ),
        ),
      );

      await tester.enterText(
        find.descendant(of: labelled('Rua'), matching: find.byType(TextField)),
        'Rua ',
      );
      await tester.pump();

      expect(fieldLabelled(tester, 'Rua').controller?.text, 'Rua ');
    });
  });

  group('errors', () {
    testWidgets('required errors only show after the person tried to save', (
      tester,
    ) async {
      await tester.pumpWidget(form(FormEvents(), draft: fakeManualDraft()));
      expect(find.text('Campo obrigatório.'), findsNothing);

      await tester.pumpWidget(
        form(FormEvents(), draft: fakeManualDraft(), showErrors: true),
      );

      expect(find.text('Campo obrigatório.'), findsNWidgets(3));
    });

    testWidgets('a blank form asks for the CEP and the street', (tester) async {
      await tester.pumpWidget(form(FormEvents(), showErrors: true));

      expect(find.text('Campo obrigatório.'), findsNWidgets(2));
    });

    testWidgets('a complete draft shows no required error', (tester) async {
      await tester.pumpWidget(
        form(FormEvents(), draft: fakeCompleteDraft(), showErrors: true),
      );

      expect(find.text('Campo obrigatório.'), findsNothing);
    });

    testWidgets('the CEP failure message replaces the required error', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(
          FormEvents(),
          showErrors: true,
          zipErrorText: 'CEP deve ter 8 dígitos.',
        ),
      );

      expect(find.text('CEP deve ter 8 dígitos.'), findsOneWidget);
      expect(find.text('Campo obrigatório.'), findsOneWidget);
    });
  });

  group('disabled', () {
    testWidgets('a disabled resolved form ignores typing', (tester) async {
      await tester.pumpWidget(
        form(FormEvents(), draft: fakeResolvedDraft(), enabled: false),
      );

      for (final label in ['CEP', 'Rua', 'Número', 'Complemento', 'Bairro']) {
        expect(fieldLabelled(tester, label).enabled, isFalse, reason: label);
      }
    });

    testWidgets('a disabled manual form shows the UF as plain text', (
      tester,
    ) async {
      await tester.pumpWidget(
        form(
          FormEvents(),
          draft: fakeManualDraft().withUf('GO'),
          enabled: false,
        ),
      );

      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.text('GO'), findsOneWidget);
      expect(fieldLabelled(tester, 'Município').enabled, isFalse);
    });

    testWidgets(
      'a disabled UF keeps the design-system color on the dark theme',
      (tester) async {
        await tester.pumpWidget(
          form(
            FormEvents(),
            draft: fakeManualDraft().withUf('GO'),
            enabled: false,
          ),
        );

        final text = tester.widget<Text>(find.text('GO'));
        expect(text.style?.color, VanepColors.textMuted);
        expect(text.style!.color!.a, 1);
      },
    );
  });

  group('postalLocationModeOf', () {
    PostalLocationMode modeOf(
      PostalAddressDraft draft, {
      bool isLookingUpCep = false,
    }) => postalLocationModeOf(draft, isLookingUpCep: isLookingUpCep);

    test('a blank draft and an incomplete CEP have no location', () {
      expect(modeOf(const PostalAddressDraft()), PostalLocationMode.none);
      expect(
        modeOf(fakeResolvedDraft().withZipCode('7212012')),
        PostalLocationMode.none,
      );
    });

    test('a pending lookup hides the location, even a resolved one', () {
      expect(
        modeOf(fakeResolvedDraft(), isLookingUpCep: true),
        PostalLocationMode.none,
      );
    });

    test('a CEP that does not exist has no location', () {
      expect(modeOf(fakeBlockedDraft()), PostalLocationMode.none);
    });

    test('a locked city is resolved', () {
      expect(modeOf(fakeResolvedDraft()), PostalLocationMode.resolved);
    });

    test('an unlocked city with a full CEP is the manual fallback', () {
      expect(modeOf(fakeManualDraft()), PostalLocationMode.manual);
      expect(modeOf(fakeManualDraft().withUf('GO')), PostalLocationMode.manual);
    });
  });
}
