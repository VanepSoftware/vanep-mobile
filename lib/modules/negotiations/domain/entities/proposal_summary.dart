import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

abstract class ProposalSummary {
  String get token;

  int get version;

  ProposalStatus get status;

  int get totalAmountCents;

  int get installments;

  int get installmentAmountCents;

  int get lastInstallmentAmountCents;

  DateTime get validUntil;

  DateTime get startsOn;

  bool get hasPendingAdjustment;
}
