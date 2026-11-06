import 'package:equatable/equatable.dart';

const schoolWeekdays = [
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];

enum RouteLeg { outbound, inbound }

enum ProposalComposeBlock { none, overdueInvoice, notAcceptingStudents }

class ProposalStudentLine extends Equatable {
  const ProposalStudentLine({
    required this.token,
    required this.name,
    required this.schoolName,
    required this.monthlyAmountCents,
  });

  final String token;

  final String name;

  final String schoolName;

  final int monthlyAmountCents;

  ProposalStudentLine withAmount(int monthlyAmountCents) {
    return ProposalStudentLine(
      token: token,
      name: name,
      schoolName: schoolName,
      monthlyAmountCents: monthlyAmountCents,
    );
  }

  @override
  List<Object?> get props => [token, name, schoolName, monthlyAmountCents];
}

class ProposalScheduleSlot extends Equatable {
  const ProposalScheduleSlot({
    required this.weekday,
    required this.leg,
    required this.minutesFromMidnight,
  });

  final int weekday;

  final RouteLeg leg;

  final int minutesFromMidnight;

  @override
  List<Object?> get props => [weekday, leg, minutesFromMidnight];
}

class ProposalScheduleDay extends Equatable {
  const ProposalScheduleDay({required this.weekday, required this.slots});

  final int weekday;

  final List<ProposalScheduleSlot> slots;

  @override
  List<Object?> get props => [weekday, slots];
}

List<ProposalScheduleDay> groupProposalSchedule(
  List<ProposalScheduleSlot> slots,
) {
  return [
    for (final weekday in schoolWeekdays)
      if (slots.any((slot) => slot.weekday == weekday))
        ProposalScheduleDay(
          weekday: weekday,
          slots: [
            for (final leg in RouteLeg.values)
              ...slots.where(
                (slot) => slot.weekday == weekday && slot.leg == leg,
              ),
          ],
        ),
  ];
}

class ProposalConditions extends Equatable {
  const ProposalConditions({required this.dueDay, required this.notes});

  final int dueDay;

  final String notes;

  @override
  List<Object?> get props => [dueDay, notes];
}

class ProposalComposeDraft extends Equatable {
  const ProposalComposeDraft({
    required this.familyName,
    required this.students,
    required this.schedule,
    required this.conditions,
    required this.commissionCents,
    required this.block,
  });

  final String familyName;

  final List<ProposalStudentLine> students;

  final List<ProposalScheduleSlot> schedule;

  final ProposalConditions conditions;

  final int commissionCents;

  final ProposalComposeBlock block;

  int get familyAmountCents => students.fold(
    0,
    (sum, student) => sum + student.monthlyAmountCents,
  );

  int get receivedCents => familyAmountCents - commissionCents;

  bool get canSend =>
      block == ProposalComposeBlock.none &&
      students.isNotEmpty &&
      students.every((student) => student.monthlyAmountCents > 0) &&
      receivedCents > 0;

  ProposalComposeDraft withStudentAmount(String token, int cents) {
    if (!students.any((student) => student.token == token)) return this;
    return ProposalComposeDraft(
      familyName: familyName,
      students: [
        for (final student in students)
          if (student.token == token)
            student.withAmount(cents)
          else
            student,
      ],
      schedule: schedule,
      conditions: conditions,
      commissionCents: commissionCents,
      block: block,
    );
  }

  @override
  List<Object?> get props => [
    familyName,
    students,
    schedule,
    conditions,
    commissionCents,
    block,
  ];
}
