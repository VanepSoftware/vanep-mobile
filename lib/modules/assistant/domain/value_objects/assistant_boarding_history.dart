import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

const assistantBoardingHistoryDays = 30;

class AssistantLegRecord extends Equatable {
  const AssistantLegRecord({
    required this.status,
    this.boardedAt,
    this.droppedOffAt,
    this.noShowReason,
    this.skipNotes,
  });

  final BoardingStatus status;
  final DateTime? boardedAt;
  final DateTime? droppedOffAt;
  final NoShowReason? noShowReason;
  final String? skipNotes;

  @override
  List<Object?> get props => [
    status,
    boardedAt,
    droppedOffAt,
    noShowReason,
    skipNotes,
  ];
}

class AssistantBoardingHistoryDay extends Equatable {
  const AssistantBoardingHistoryDay({
    required this.date,
    this.outbound,
    this.inbound,
  });

  final DateTime date;
  final AssistantLegRecord? outbound;
  final AssistantLegRecord? inbound;

  @override
  List<Object?> get props => [date, outbound, inbound];
}

List<AssistantBoardingHistoryDay> latestHistoryFirst(
  List<AssistantBoardingHistoryDay> days, {
  required DateTime now,
}) {
  final cutoff = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: assistantBoardingHistoryDays));
  return days.where((day) => !day.date.isBefore(cutoff)).toList()
    ..sort((first, second) => second.date.compareTo(first.date));
}
