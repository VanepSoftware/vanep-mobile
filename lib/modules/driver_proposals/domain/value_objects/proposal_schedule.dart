import 'package:equatable/equatable.dart';

const schoolWeekdays = [
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];

enum RouteLeg { outbound, inbound }

enum ProposalLegs { outboundAndReturn, outboundOnly, returnOnly, none }

class ProposalScheduleSlot extends Equatable {
  const ProposalScheduleSlot({required this.weekday, required this.leg});

  final int weekday;

  final RouteLeg leg;

  @override
  List<Object?> get props => [weekday, leg];
}

Set<ProposalScheduleSlot> fullSchoolWeekSlots() {
  return {
    for (final weekday in schoolWeekdays)
      for (final leg in RouteLeg.values)
        ProposalScheduleSlot(weekday: weekday, leg: leg),
  };
}

Set<ProposalScheduleSlot> toggleProposalSlot(
  Set<ProposalScheduleSlot> slots,
  ProposalScheduleSlot slot,
) {
  if (slots.contains(slot)) return {...slots}..remove(slot);
  return {...slots, slot};
}

ProposalLegs proposalLegsOf(Set<ProposalScheduleSlot> slots) {
  final hasOutbound = slots.any((slot) => slot.leg == RouteLeg.outbound);
  final hasReturn = slots.any((slot) => slot.leg == RouteLeg.inbound);
  if (hasOutbound && hasReturn) return ProposalLegs.outboundAndReturn;
  if (hasOutbound) return ProposalLegs.outboundOnly;
  if (hasReturn) return ProposalLegs.returnOnly;
  return ProposalLegs.none;
}
