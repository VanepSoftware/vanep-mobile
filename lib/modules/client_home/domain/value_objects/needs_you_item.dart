import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

enum NeedsYouTier { signature, proposal, payment, followUp }

sealed class NeedsYouItem extends Equatable {
  const NeedsYouItem();

  NeedsYouTier get tier;

  DateTime? get deadline;

  bool get isFeaturable => false;
}

final class ContractToSignItem extends NeedsYouItem {
  const ContractToSignItem({
    required this.childName,
    required this.driverName,
    required this.monthlyFeeCents,
    required this.signBy,
  });

  final String childName;

  final String driverName;

  final int monthlyFeeCents;

  final DateTime signBy;

  @override
  NeedsYouTier get tier => NeedsYouTier.signature;

  @override
  DateTime? get deadline => signBy;

  @override
  bool get isFeaturable => true;

  @override
  List<Object?> get props => [childName, driverName, monthlyFeeCents, signBy];
}

final class NewProposalItem extends NeedsYouItem {
  const NewProposalItem({required this.request});

  final ClientServiceRequest request;

  String get driverName => request.driverName;

  List<String> get childNames => [
    for (final item in request.items) item.dependentName,
  ];

  int get installments => request.currentProposal?.installments ?? 0;

  int get installmentAmountCents =>
      request.currentProposal?.installmentAmountCents ?? 0;

  DateTime? get expiresAt => request.currentProposal?.validUntil;

  @override
  NeedsYouTier get tier => NeedsYouTier.proposal;

  @override
  DateTime? get deadline => expiresAt;

  @override
  bool get isFeaturable => true;

  @override
  List<Object?> get props => [request];
}

final class ExpiredRequestItem extends NeedsYouItem {
  const ExpiredRequestItem({required this.driverName});

  final String driverName;

  @override
  NeedsYouTier get tier => NeedsYouTier.proposal;

  @override
  DateTime? get deadline => null;

  @override
  List<Object?> get props => [driverName];
}

final class PaymentItem extends NeedsYouItem {
  const PaymentItem({
    required this.amountCents,
    required this.dueAt,
    this.childName,
    this.awaitingConfirmationFrom,
  });

  final int amountCents;

  final DateTime dueAt;

  final String? childName;

  final String? awaitingConfirmationFrom;

  bool get isAwaitingConfirmation => awaitingConfirmationFrom != null;

  @override
  NeedsYouTier get tier => NeedsYouTier.payment;

  @override
  DateTime? get deadline => dueAt;

  @override
  List<Object?> get props => [
    amountCents,
    dueAt,
    childName,
    awaitingConfirmationFrom,
  ];
}

final class RenewalItem extends NeedsYouItem {
  const RenewalItem({required this.driverName, required this.year});

  final String driverName;

  final int year;

  @override
  NeedsYouTier get tier => NeedsYouTier.followUp;

  @override
  DateTime? get deadline => null;

  @override
  List<Object?> get props => [driverName, year];
}

final class VehicleInspectionExpiredItem extends NeedsYouItem {
  const VehicleInspectionExpiredItem({
    required this.driverName,
    required this.regularizeBy,
  });

  final String driverName;

  final DateTime regularizeBy;

  @override
  NeedsYouTier get tier => NeedsYouTier.followUp;

  @override
  DateTime? get deadline => regularizeBy;

  @override
  List<Object?> get props => [driverName, regularizeBy];
}

final class RateDriverItem extends NeedsYouItem {
  const RateDriverItem({required this.driverName});

  final String driverName;

  @override
  NeedsYouTier get tier => NeedsYouTier.followUp;

  @override
  DateTime? get deadline => null;

  @override
  List<Object?> get props => [driverName];
}

class NeedsYouSummary extends Equatable {
  const NeedsYouSummary({this.visible = const [], this.hiddenCount = 0});

  final List<NeedsYouItem> visible;

  final int hiddenCount;

  bool get isEmpty => visible.isEmpty;

  bool get hasMore => hiddenCount > 0;

  NeedsYouItem? get featured {
    final first = visible.isEmpty ? null : visible.first;
    return first != null && first.isFeaturable ? first : null;
  }

  List<NeedsYouItem> get rows =>
      featured == null ? visible : visible.skip(1).toList();

  @override
  List<Object?> get props => [visible, hiddenCount];
}
