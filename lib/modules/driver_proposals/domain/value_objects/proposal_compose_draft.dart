import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';

const proposalMessageMaxLength = 500;

enum ProposalComposeBlock { none, overdueInvoice, notAcceptingStudents }

class ProposalStudentLine extends Equatable {
  const ProposalStudentLine({
    required this.token,
    required this.name,
    required this.monthlyAmountCents,
  });

  final String token;

  final String name;

  final int monthlyAmountCents;

  ProposalStudentLine withAmount(int monthlyAmountCents) {
    return ProposalStudentLine(
      token: token,
      name: name,
      monthlyAmountCents: monthlyAmountCents,
    );
  }

  @override
  List<Object?> get props => [token, name, monthlyAmountCents];
}

class ProposalVanOption extends Equatable {
  const ProposalVanOption({
    required this.token,
    required this.model,
    required this.plate,
    required this.capacity,
    required this.freeSeats,
  });

  final String token;

  final String model;

  final String plate;

  final int capacity;

  final int freeSeats;

  @override
  List<Object?> get props => [token, model, plate, capacity, freeSeats];
}

class ProposalComposeDraft extends Equatable {
  const ProposalComposeDraft({
    required this.familyName,
    required this.students,
    required this.vans,
    required this.selectedVanToken,
    required this.shift,
    required this.requestedSlots,
    required this.slots,
    required this.times,
    required this.payment,
    required this.conditions,
    required this.commissionCents,
    required this.validityDays,
    required this.block,
    this.message = '',
  });

  final String familyName;

  final List<ProposalStudentLine> students;

  final List<ProposalVanOption> vans;

  final String selectedVanToken;

  final SchoolShift shift;

  final Set<ProposalScheduleSlot> requestedSlots;

  final Set<ProposalScheduleSlot> slots;

  final ProposalRouteTimes times;

  final ProposalPayment payment;

  final ProposalConditions conditions;

  final int commissionCents;

  final int validityDays;

  final ProposalComposeBlock block;

  final String message;

  ProposalVanOption? get selectedVan =>
      vans.where((van) => van.token == selectedVanToken).firstOrNull;

  int get monthlyFamilyCents => students.fold(
    0,
    (sum, student) => sum + student.monthlyAmountCents,
  );

  int get monthlyReceivedCents => monthlyFamilyCents - commissionCents;

  int get familyTotalCents => monthlyFamilyCents * payment.installments;

  int get commissionTotalCents => commissionCents * payment.installments;

  int get receivedTotalCents => familyTotalCents - commissionTotalCents;

  bool get hasSeatsForStudents {
    final van = selectedVan;
    return van != null && van.freeSeats >= students.length;
  }

  bool get matchesRequest =>
      slots.length == requestedSlots.length && slots.containsAll(requestedSlots);

  ProposalLegs get legs => proposalLegsOf(slots);

  bool get hasValidPrices =>
      students.isNotEmpty &&
      students.every((student) => student.monthlyAmountCents > 0) &&
      receivedTotalCents > 0;

  bool get canSend =>
      block == ProposalComposeBlock.none &&
      hasValidPrices &&
      hasSeatsForStudents &&
      slots.isNotEmpty &&
      times.isValid &&
      payment.isValid;

  ProposalComposeDraft withStudentAmount(String token, int cents) {
    if (!students.any((student) => student.token == token)) return this;
    return copyWith(
      students: [
        for (final student in students)
          if (student.token == token) student.withAmount(cents) else student,
      ],
    );
  }

  ProposalComposeDraft withVan(String token) {
    if (!vans.any((van) => van.token == token)) return this;
    return copyWith(selectedVanToken: token);
  }

  ProposalComposeDraft withSlotToggled(ProposalScheduleSlot slot) {
    return copyWith(slots: toggleProposalSlot(slots, slot));
  }

  ProposalComposeDraft copyWith({
    List<ProposalStudentLine>? students,
    String? selectedVanToken,
    Set<ProposalScheduleSlot>? slots,
    ProposalRouteTimes? times,
    ProposalPayment? payment,
    ProposalConditions? conditions,
    String? message,
  }) {
    return ProposalComposeDraft(
      familyName: familyName,
      students: students ?? this.students,
      vans: vans,
      selectedVanToken: selectedVanToken ?? this.selectedVanToken,
      shift: shift,
      requestedSlots: requestedSlots,
      slots: slots ?? this.slots,
      times: times ?? this.times,
      payment: payment ?? this.payment,
      conditions: conditions ?? this.conditions,
      commissionCents: commissionCents,
      validityDays: validityDays,
      block: block,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    familyName,
    students,
    vans,
    selectedVanToken,
    shift,
    requestedSlots,
    slots,
    times,
    payment,
    conditions,
    commissionCents,
    validityDays,
    block,
    message,
  ];
}
