import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/legs_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

import '../negotiations_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test('labels the adjustment policies', () {
    expect(
      adjustmentPolicyLabel(l10n, ProposalAdjustmentPolicy.none),
      'Sem reajuste',
    );
    expect(
      adjustmentPolicyLabel(l10n, ProposalAdjustmentPolicy.ipcaAtRenewal),
      'IPCA na renovação',
    );
  });

  test('labels the cancellation policies', () {
    expect(
      cancellationPolicyLabel(l10n, ProposalCancellationPolicy.notice30Days),
      'Aviso de 30 dias',
    );
    expect(
      cancellationPolicyLabel(
        l10n,
        ProposalCancellationPolicy.notice30DaysWithFee,
      ),
      'Aviso de 30 dias + 10%',
    );
  });

  test('labels the subjects of an adjustment', () {
    expect(
      ProposalAdjustmentField.values.map(
        (field) => adjustmentFieldLabel(l10n, field),
      ),
      ['Valor', 'Parcelas', 'Dias e horários', 'Período do contrato', 'Outro'],
    );
  });

  test('labels every turn of the client, closed ones as the outcome', () {
    expect(ClientTurn.values.map((turn) => clientTurnLabel(l10n, turn)), [
      'Pedido enviado',
      'Proposta recebida',
      'Ajuste solicitado',
      'Aceita',
      'Recusada pelo motorista',
      'Encerrada por você',
      'Expirada',
    ]);
  });

  test('labels the legs and their summary', () {
    expect(routeLegLabel(l10n, RouteLeg.outbound), 'Ida');
    expect(routeLegLabel(l10n, RouteLeg.homebound), 'Volta');
    expect(
      LegsSummary.values.map((summary) => legsSummaryLabel(l10n, summary)),
      ['ida e volta', 'só ida', 'só volta', 'ida e volta em alguns dias'],
    );
  });

  test('has an English label for each of them', () async {
    final english = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      adjustmentPolicyLabel(english, ProposalAdjustmentPolicy.none),
      'No adjustment',
    );
    expect(
      clientTurnLabel(english, ClientTurn.closedByClient),
      'Closed by you',
    );
    expect(
      legsSummaryLabel(english, LegsSummary.outboundOnly),
      'outbound only',
    );
  });

  test('tells each failure, with the message of the back when it has one', () {
    expect(
      negotiationFailureMessage(l10n, const NegotiationNetworkFailure()),
      'Sem conexão. Confira a internet e tente de novo.',
    );
    expect(
      negotiationFailureMessage(l10n, const NegotiationNotFoundFailure()),
      'Esta negociação não está mais disponível.',
    );
    expect(
      negotiationFailureMessage(l10n, const NegotiationInvalidFailure()),
      'Confira os dados e tente de novo.',
    );
    expect(
      negotiationFailureMessage(
        l10n,
        const NegotiationConflictFailure(detail: 'A versão 2 chegou.'),
      ),
      'A versão 2 chegou.',
    );
    expect(
      negotiationFailureMessage(
        l10n,
        const NegotiationRejectedFailure(detail: 'Limite de 5 pedidos.'),
      ),
      'Limite de 5 pedidos.',
    );
    expect(
      negotiationFailureMessage(
        l10n,
        const NegotiationRejectedFailure(detail: ' '),
      ),
      'Não foi possível concluir agora. Tente de novo.',
    );
    expect(
      negotiationFailureMessage(l10n, const NegotiationUnexpectedFailure()),
      'Não foi possível concluir agora. Tente de novo.',
    );
  });

  test('labels every status of a proposal', () {
    expect(
      ProposalStatus.values.map((status) => proposalStatusLabel(l10n, status)),
      [
        'Aberta',
        'Aceita',
        'Substituída',
        'Recusada',
        'Vencida',
        'Retirada pelo motorista',
      ],
    );
  });

  test('shows the time and the van of a proposal', () {
    expect(formatClockTime(const ClockTime(hour: 6, minute: 40)), '06:40');
    expect(
      formatProposalVehicle(l10n, const TestProposalVehicle()),
      'Master 2019 · 15 lugares',
    );
  });

  test('names each event of the history', () {
    final at = DateTime.utc(2026, 10, 2);

    expect(
      negotiationEventTitle(l10n, RequestSentEvent(at: at)),
      'Pedido de orçamento',
    );
    expect(
      negotiationEventTitle(
        l10n,
        ProposalSentEvent(
          at: at,
          proposalToken: 'proposal-v2',
          version: 2,
          isOpen: true,
        ),
      ),
      'Versão 2',
    );
    expect(
      negotiationEventTitle(
        l10n,
        AdjustmentRequestedEvent(
          at: at,
          field: ProposalAdjustmentField.price,
          suggestedValue: 'R\$ 290',
        ),
      ),
      'Ajuste pedido · R\$ 290',
    );
    expect(
      negotiationEventTitle(
        l10n,
        AdjustmentRequestedEvent(
          at: at,
          field: ProposalAdjustmentField.schedule,
          suggestedValue: ' ',
        ),
      ),
      'Ajuste pedido · Dias e horários',
    );
    expect(
      negotiationEventTitle(l10n, ProposalAcceptedEvent(at: at, version: 2)),
      'Proposta aceita',
    );
    expect(
      negotiationEventTitle(l10n, ProposalDeclinedEvent(at: at, version: 2)),
      'Proposta recusada',
    );
    expect(
      negotiationEventTitle(l10n, RequestDeclinedEvent(at: at)),
      'Pedido recusado pelo motorista',
    );
  });

  test('the shift of a school is the only one or varies', () {
    SchoolGroup<TestDriverRequestItem> groupOf(List<SchoolShift> shifts) {
      return groupItemsBySchool([
        TestDriverRequestItem(
          days: [
            for (final (index, shift) in shifts.indexed)
              TestRequestedDay(
                weekday: Weekday.values[index],
                schoolShift: shift,
              ),
          ],
        ),
      ]).single;
    }

    expect(formatSchoolShift(l10n, groupOf([SchoolShift.afternoon])), 'tarde');
    expect(
      formatSchoolShift(
        l10n,
        groupOf([SchoolShift.morning, SchoolShift.afternoon]),
      ),
      'turno varia',
    );
  });
}
