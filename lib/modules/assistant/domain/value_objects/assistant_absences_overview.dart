import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

class AssistantAbsenceRow extends Equatable {
  const AssistantAbsenceRow({
    required this.passengerNames,
    required this.passengerTokens,
    required this.date,
    required this.kind,
    required this.source,
    required this.notifiedAt,
    this.stopChangeLabel,
  });

  final List<String> passengerNames;
  final List<String> passengerTokens;
  final DateTime date;
  final AbsenceKind kind;
  final AbsenceSource source;
  final DateTime notifiedAt;
  final String? stopChangeLabel;

  @override
  List<Object?> get props => [
    passengerNames,
    passengerTokens,
    date,
    kind,
    source,
    notifiedAt,
    stopChangeLabel,
  ];
}

class AssistantAbsencesOverview extends Equatable {
  const AssistantAbsencesOverview({
    this.today = const [],
    this.upcoming = const [],
  });

  final List<AssistantAbsenceRow> today;
  final List<AssistantAbsenceRow> upcoming;

  @override
  List<Object?> get props => [today, upcoming];
}
