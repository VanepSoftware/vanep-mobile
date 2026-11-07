import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

sealed class NegotiationEvent extends Equatable {
  const NegotiationEvent({required this.at});

  final DateTime at;

  @override
  List<Object?> get props => [at];
}

final class RequestSentEvent extends NegotiationEvent {
  const RequestSentEvent({required super.at});
}

final class ProposalSentEvent extends NegotiationEvent {
  const ProposalSentEvent({
    required super.at,
    required this.proposalToken,
    required this.version,
    required this.installments,
    required this.installmentAmountCents,
    required this.isOpen,
  });

  final String proposalToken;

  final int version;

  final int installments;

  final int installmentAmountCents;

  final bool isOpen;

  @override
  List<Object?> get props => [
    at,
    proposalToken,
    version,
    installments,
    installmentAmountCents,
    isOpen,
  ];
}

final class AdjustmentRequestedEvent extends NegotiationEvent {
  const AdjustmentRequestedEvent({
    required super.at,
    required this.field,
    this.suggestedValue,
    this.note,
  });

  final ProposalAdjustmentField field;

  final String? suggestedValue;

  final String? note;

  @override
  List<Object?> get props => [at, field, suggestedValue, note];
}

final class ProposalAcceptedEvent extends NegotiationEvent {
  const ProposalAcceptedEvent({required super.at, required this.version});

  final int version;

  @override
  List<Object?> get props => [at, version];
}

final class ProposalDeclinedEvent extends NegotiationEvent {
  const ProposalDeclinedEvent({required super.at, required this.version});

  final int version;

  @override
  List<Object?> get props => [at, version];
}

final class RequestDeclinedEvent extends NegotiationEvent {
  const RequestDeclinedEvent({required super.at});
}

List<NegotiationEvent> buildNegotiationHistory(
  ServiceRequest request,
  List<Proposal> versions,
) {
  final versionsInOrder = [...versions]
    ..sort((first, second) => first.version.compareTo(second.version));
  final events = [
    RequestSentEvent(at: request.createdAt),
    for (final proposal in versionsInOrder) ...eventsOfVersion(proposal),
    if (request.status == ServiceRequestStatus.declined)
      RequestDeclinedEvent(at: request.updatedAt),
  ];
  return sortEventsByDate(events);
}

List<NegotiationEvent> eventsOfVersion(Proposal proposal) {
  return [
    ProposalSentEvent(
      at: proposal.createdAt,
      proposalToken: proposal.token,
      version: proposal.version,
      installments: proposal.installments,
      installmentAmountCents: proposal.installmentAmountCents,
      isOpen: proposal.status == ProposalStatus.sent,
    ),
    for (final adjustment in proposal.adjustments)
      AdjustmentRequestedEvent(
        at: adjustment.createdAt,
        field: adjustment.field,
        suggestedValue: adjustment.suggestedValue,
        note: adjustment.note,
      ),
    if (proposal.status == ProposalStatus.accepted)
      ProposalAcceptedEvent(
        at: proposal.acceptedAt ?? proposal.updatedAt,
        version: proposal.version,
      ),
    if (proposal.status == ProposalStatus.declined)
      ProposalDeclinedEvent(at: proposal.updatedAt, version: proposal.version),
  ];
}

List<NegotiationEvent> sortEventsByDate(List<NegotiationEvent> events) {
  final positions = [for (var index = 0; index < events.length; index++) index]
    ..sort((first, second) {
      final byDate = events[first].at.compareTo(events[second].at);
      return byDate != 0 ? byDate : first.compareTo(second);
    });
  return [for (final position in positions) events[position]];
}
