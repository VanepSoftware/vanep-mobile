import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';

enum ProposalOutcome { accepted, declined, expired, cancelled }

sealed class ChildProposalEntry extends Equatable {
  const ChildProposalEntry();

  String get childToken;
}

class ProposalDriver extends Equatable {
  const ProposalDriver({
    required this.name,
    required this.vehicleModel,
    required this.vehicleYear,
    this.rating,
    this.gender,
  });

  final String name;

  final String vehicleModel;

  final int vehicleYear;

  final double? rating;

  final Gender? gender;

  bool get isNewOnVanep => rating == null;

  @override
  List<Object?> get props => [name, vehicleModel, vehicleYear, rating, gender];
}

final class PendingProposal extends ChildProposalEntry {
  const PendingProposal({
    required this.token,
    required this.driver,
    required this.childToken,
    required this.childName,
    required this.schoolName,
    required this.shift,
    required this.weekdays,
    required this.startsOn,
    required this.monthlyFeeCents,
    required this.expiresAt,
    this.previousMonthlyFeeCents,
  });

  final String token;

  final ProposalDriver driver;

  @override
  final String childToken;

  final String childName;

  final String schoolName;

  final SchoolShift shift;

  final List<int> weekdays;

  final DateTime startsOn;

  final int monthlyFeeCents;

  final int? previousMonthlyFeeCents;

  final DateTime expiresAt;

  @override
  List<Object?> get props => [
    token,
    driver,
    childToken,
    childName,
    schoolName,
    shift,
    weekdays,
    startsOn,
    monthlyFeeCents,
    previousMonthlyFeeCents,
    expiresAt,
  ];
}

final class SentRequest extends ChildProposalEntry {
  const SentRequest({
    required this.token,
    required this.driverName,
    required this.childToken,
    required this.childName,
    required this.sentAt,
    required this.answerBy,
  });

  final String token;

  final String driverName;

  @override
  final String childToken;

  final String childName;

  final DateTime sentAt;

  final DateTime answerBy;

  @override
  List<Object?> get props => [
    token,
    driverName,
    childToken,
    childName,
    sentAt,
    answerBy,
  ];
}

final class ClosedProposal extends ChildProposalEntry {
  const ClosedProposal({
    required this.token,
    required this.driverName,
    required this.childToken,
    required this.childName,
    required this.monthlyFeeCents,
    required this.outcome,
    required this.closedAt,
  });

  final String token;

  final String driverName;

  @override
  final String childToken;

  final String childName;

  final int monthlyFeeCents;

  final ProposalOutcome outcome;

  final DateTime closedAt;

  @override
  List<Object?> get props => [
    token,
    driverName,
    childToken,
    childName,
    monthlyFeeCents,
    outcome,
    closedAt,
  ];
}
