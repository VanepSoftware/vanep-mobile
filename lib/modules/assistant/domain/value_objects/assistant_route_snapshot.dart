import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_trip_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';

class AssistantRoutePassenger extends Equatable {
  const AssistantRoutePassenger({
    required this.token,
    required this.name,
    required this.schoolName,
    required this.checklistStatus,
    this.photoUrl,
    this.siblingTokens = const [],
    this.confirmedAt,
    this.noShowReason,
    this.skipNotes,
  });

  final String token;
  final String name;
  final String schoolName;
  final ChecklistStatus checklistStatus;
  final String? photoUrl;
  final List<String> siblingTokens;
  final DateTime? confirmedAt;
  final NoShowReason? noShowReason;
  final String? skipNotes;

  @override
  List<Object?> get props => [
    token,
    name,
    schoolName,
    checklistStatus,
    photoUrl,
    siblingTokens,
    confirmedAt,
    noShowReason,
    skipNotes,
  ];
}

class AssistantRouteStop extends Equatable {
  const AssistantRouteStop({
    required this.token,
    required this.kind,
    required this.sequence,
    required this.status,
    required this.label,
    this.plannedArrivalAt,
    this.completedAt,
    this.passengers = const [],
  });

  final String token;
  final RouteStopKind kind;
  final int sequence;
  final RouteStopStatus status;
  final String label;
  final DateTime? plannedArrivalAt;
  final DateTime? completedAt;
  final List<AssistantRoutePassenger> passengers;

  @override
  List<Object?> get props => [
    token,
    kind,
    sequence,
    status,
    label,
    plannedArrivalAt,
    completedAt,
    passengers,
  ];
}

class AssistantRouteSnapshot extends Equatable {
  const AssistantRouteSnapshot({
    required this.tripToken,
    required this.tripStatus,
    this.shift,
    this.startedAt,
    this.departureAt,
    this.stops = const [],
    this.todayAbsences = const [],
  });

  final String tripToken;
  final AssistantTripStatus tripStatus;
  final String? shift;
  final DateTime? startedAt;
  final DateTime? departureAt;
  final List<AssistantRouteStop> stops;
  final List<AssistantAbsence> todayAbsences;

  @override
  List<Object?> get props => [
    tripToken,
    tripStatus,
    shift,
    startedAt,
    departureAt,
    stops,
    todayAbsences,
  ];
}
