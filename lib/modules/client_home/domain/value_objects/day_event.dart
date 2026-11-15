import 'package:equatable/equatable.dart';

enum DayEventKind { droppedAtSchool, boardedAtHome, routeStarted, absence }

class DayEvent extends Equatable {
  const DayEvent({
    required this.kind,
    required this.at,
    this.actorName,
    this.childName,
  });

  final DayEventKind kind;

  final DateTime at;

  final String? actorName;

  final String? childName;

  @override
  List<Object?> get props => [kind, at, actorName, childName];
}
