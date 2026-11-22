import 'package:equatable/equatable.dart';

enum AbsenceKind {
  notGoing,
  outboundOnly,
  returnOnly,
  stopChange;

  static AbsenceKind? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'NOT_GOING' => AbsenceKind.notGoing,
      'OUTBOUND_ONLY' => AbsenceKind.outboundOnly,
      'RETURN_ONLY' => AbsenceKind.returnOnly,
      'STOP_CHANGE' => AbsenceKind.stopChange,
      _ => null,
    };
  }

  static String toApi(AbsenceKind kind) {
    return switch (kind) {
      AbsenceKind.notGoing => 'NOT_GOING',
      AbsenceKind.outboundOnly => 'OUTBOUND_ONLY',
      AbsenceKind.returnOnly => 'RETURN_ONLY',
      AbsenceKind.stopChange => 'STOP_CHANGE',
    };
  }
}

enum AbsenceSource {
  client,
  driver,
  assistant;

  static AbsenceSource? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'CLIENT' => AbsenceSource.client,
      'DRIVER' => AbsenceSource.driver,
      'ASSISTANT' => AbsenceSource.assistant,
      _ => null,
    };
  }

  static String toApi(AbsenceSource source) {
    return switch (source) {
      AbsenceSource.client => 'CLIENT',
      AbsenceSource.driver => 'DRIVER',
      AbsenceSource.assistant => 'ASSISTANT',
    };
  }
}

class AssistantAbsence extends Equatable {
  const AssistantAbsence({
    required this.passengerToken,
    required this.passengerName,
    required this.date,
    required this.kind,
    required this.source,
    required this.notifiedAt,
    this.stopChangeLabel,
    this.contractToken,
  });

  final String? contractToken;
  final String passengerToken;
  final String passengerName;
  final DateTime date;
  final AbsenceKind kind;
  final AbsenceSource source;
  final DateTime notifiedAt;
  final String? stopChangeLabel;

  @override
  List<Object?> get props => [
    contractToken,
    passengerToken,
    passengerName,
    date,
    kind,
    source,
    notifiedAt,
    stopChangeLabel,
  ];
}
