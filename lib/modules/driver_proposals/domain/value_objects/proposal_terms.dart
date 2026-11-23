import 'package:equatable/equatable.dart';

const maxProposalInstallments = 12;

const proposalDueDayOptions = [5, 10, 15, 20, 25];

const proposalStopWaitOptions = [3, 5, 10];

const proposalCancellationNoticeOptions = [15, 30, 60];

const proposalCancellationPenaltyOptions = [0, 10, 20];

class ProposalRouteTimes extends Equatable {
  const ProposalRouteTimes({
    required this.pickupStartMinutes,
    required this.pickupEndMinutes,
    required this.schoolArrivalMinutes,
    required this.schoolDepartureMinutes,
    required this.stopWaitMinutes,
  });

  final int pickupStartMinutes;

  final int pickupEndMinutes;

  final int schoolArrivalMinutes;

  final int schoolDepartureMinutes;

  final int stopWaitMinutes;

  bool get isValid =>
      pickupStartMinutes <= pickupEndMinutes &&
      pickupEndMinutes <= schoolArrivalMinutes &&
      stopWaitMinutes > 0;

  ProposalRouteTimes copyWith({
    int? pickupStartMinutes,
    int? pickupEndMinutes,
    int? schoolArrivalMinutes,
    int? schoolDepartureMinutes,
    int? stopWaitMinutes,
  }) {
    return ProposalRouteTimes(
      pickupStartMinutes: pickupStartMinutes ?? this.pickupStartMinutes,
      pickupEndMinutes: pickupEndMinutes ?? this.pickupEndMinutes,
      schoolArrivalMinutes: schoolArrivalMinutes ?? this.schoolArrivalMinutes,
      schoolDepartureMinutes:
          schoolDepartureMinutes ?? this.schoolDepartureMinutes,
      stopWaitMinutes: stopWaitMinutes ?? this.stopWaitMinutes,
    );
  }

  @override
  List<Object?> get props => [
    pickupStartMinutes,
    pickupEndMinutes,
    schoolArrivalMinutes,
    schoolDepartureMinutes,
    stopWaitMinutes,
  ];
}

class ProposalPayment extends Equatable {
  const ProposalPayment({
    required this.installments,
    required this.dueDay,
    required this.startDate,
    required this.endDate,
  });

  final int installments;

  final int dueDay;

  final DateTime startDate;

  final DateTime endDate;

  bool get isValid =>
      installments >= 1 &&
      installments <= maxProposalInstallments &&
      dueDay >= 1 &&
      dueDay <= 28 &&
      endDate.isAfter(startDate);

  ProposalPayment copyWith({
    int? installments,
    int? dueDay,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ProposalPayment(
      installments: installments ?? this.installments,
      dueDay: dueDay ?? this.dueDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [installments, dueDay, startDate, endDate];
}

enum ProposalReservationFee { none, oneInstallmentDeducted }

enum ProposalReadjustment { ipcaOnRenewal, igpmOnRenewal, none }

class ProposalConditions extends Equatable {
  const ProposalConditions({
    required this.reservationFee,
    required this.readjustment,
    required this.cancellationNoticeDays,
    required this.cancellationPenaltyPercent,
  });

  final ProposalReservationFee reservationFee;

  final ProposalReadjustment readjustment;

  final int cancellationNoticeDays;

  final int cancellationPenaltyPercent;

  ProposalConditions copyWith({
    ProposalReservationFee? reservationFee,
    ProposalReadjustment? readjustment,
    int? cancellationNoticeDays,
    int? cancellationPenaltyPercent,
  }) {
    return ProposalConditions(
      reservationFee: reservationFee ?? this.reservationFee,
      readjustment: readjustment ?? this.readjustment,
      cancellationNoticeDays:
          cancellationNoticeDays ?? this.cancellationNoticeDays,
      cancellationPenaltyPercent:
          cancellationPenaltyPercent ?? this.cancellationPenaltyPercent,
    );
  }

  @override
  List<Object?> get props => [
    reservationFee,
    readjustment,
    cancellationNoticeDays,
    cancellationPenaltyPercent,
  ];
}
