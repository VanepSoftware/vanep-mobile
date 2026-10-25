import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_labels.dart';

import '../conversations_fixtures.dart';

void main() {
  final l10n = AppLocalizationsPt();

  setUpAll(() => initializeDateFormatting('pt'));

  test('the client sees the driver role with the proposal vehicle', () {
    expect(
      formatCounterpartRole(
        l10n,
        ConversationParticipant.client,
        fullNegotiation,
      ),
      'Motorista · Master 2019',
    );
    expect(
      formatCounterpartRole(
        l10n,
        ConversationParticipant.client,
        ConversationNegotiation.none,
      ),
      'Motorista',
    );
    expect(
      formatCounterpartRole(
        l10n,
        ConversationParticipant.driver,
        fullNegotiation,
      ),
      'Responsável',
    );
  });

  test('the day divider spells the month out', () {
    expect(formatChatDay(l10n, DateTime(2026, 10, 10)), '10 de outubro');
  });

  test('the quote request lines follow the design', () {
    expect(
      formatQuoteRequestChild(l10n, quoteRequest),
      'Pedro, 11 · Colégio Delta, tarde',
    );
    expect(
      formatQuoteRequestSchedule(l10n, quoteRequest),
      'Seg a sex · quarta só ida',
    );
    expect(formatQuoteRequestStart(l10n, quoteRequest), 'A partir de 1º fev');
    expect(
      formatQuoteRequestBoarding(l10n, quoteRequest),
      'Embarque em QNL 5, Taguatinga',
    );
  });

  test('a request without age or one-way days stays short', () {
    final request = QuoteRequestEvent(
      token: 'request-2',
      author: ConversationParticipant.client,
      occurredAt: DateTime(2026, 10, 10),
      childName: 'Ana',
      schoolName: 'Escola Sol',
      shift: quoteRequest.shift,
      weekdays: const [DateTime.monday, DateTime.wednesday],
      startsOn: DateTime(2027, 3, 2),
      boardingPlace: 'Rua 1',
    );

    expect(formatQuoteRequestChild(l10n, request), 'Ana · Escola Sol, tarde');
    expect(formatQuoteRequestSchedule(l10n, request), 'Seg, qua');
  });

  test('the proposal terms follow the design', () {
    expect(formatMonthlyFee(l10n, 34000), 'R\$ 340/mês');
    expect(
      formatProposalInstallments(l10n, secondProposal),
      '12 parcelas · vence dia 10',
    );
    expect(formatProposalPeriod(l10n, secondProposal), '1º fev a 17 dez 2027');
    expect(formatProposalExpiry(l10n, secondProposal), 'Expira em 21/10');
    expect(
      formatProposalBannerTerms(l10n, secondProposal),
      ' · R\$ 300/mês · expira em 21/10',
    );
  });

  test('cards sent by the viewer are signed with the time', () {
    expect(formatSentByViewer(l10n, quoteRequest), 'Você · 20:14');
  });
}
