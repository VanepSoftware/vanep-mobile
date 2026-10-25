import 'package:equatable/equatable.dart';

enum SchoolShift { morning, afternoon }

enum TripLeg { going, returning }

enum TripStage { boarding, school, departure, home }

class VanDay extends Equatable {
  const VanDay({
    required this.driverName,
    required this.vehicleModel,
    required this.plate,
    required this.shift,
    required this.departureAt,
    required this.riders,
    required this.schedule,
    this.live,
    this.stopChange,
  });

  final String driverName;

  final String vehicleModel;

  final String plate;

  final SchoolShift shift;

  final DateTime departureAt;

  final List<VanRider> riders;

  final VanSchedule schedule;

  final LiveTrip? live;

  final StopChange? stopChange;

  List<VanRider> get absentRiders =>
      riders.where((rider) => rider.absentToday).toList();

  List<VanRider> get presentRiders =>
      riders.where((rider) => !rider.absentToday).toList();

  @override
  List<Object?> get props => [
    driverName,
    vehicleModel,
    plate,
    shift,
    departureAt,
    riders,
    schedule,
    live,
    stopChange,
  ];
}

class VanRider extends Equatable {
  const VanRider({required this.name, this.absentToday = false});

  final String name;

  final bool absentToday;

  @override
  List<Object?> get props => [name, absentToday];
}

class VanSchedule extends Equatable {
  const VanSchedule({
    required this.boardingStartAt,
    required this.boardingEndAt,
    required this.schoolArrivalAt,
    required this.schoolDepartureAt,
  });

  final DateTime boardingStartAt;

  final DateTime boardingEndAt;

  final DateTime schoolArrivalAt;

  final DateTime schoolDepartureAt;

  @override
  List<Object?> get props => [
    boardingStartAt,
    boardingEndAt,
    schoolArrivalAt,
    schoolDepartureAt,
  ];
}

class LiveTrip extends Equatable {
  const LiveTrip({
    required this.leg,
    required this.stage,
    required this.etaMinutes,
    required this.etaAt,
    required this.updatedAt,
    this.approaching = false,
    this.crewNames = const [],
  });

  final TripLeg leg;

  final TripStage stage;

  final int etaMinutes;

  final DateTime etaAt;

  final DateTime updatedAt;

  final bool approaching;

  final List<String> crewNames;

  @override
  List<Object?> get props => [
    leg,
    stage,
    etaMinutes,
    etaAt,
    updatedAt,
    approaching,
    crewNames,
  ];
}

class StopChange extends Equatable {
  const StopChange({
    required this.childName,
    required this.leg,
    required this.placeLabel,
  });

  final String childName;

  final TripLeg leg;

  final String placeLabel;

  @override
  List<Object?> get props => [childName, leg, placeLabel];
}

enum DayMilestoneKind {
  homeBoarding,
  schoolArrival,
  schoolDeparture,
  homeArrival,
}

class ChildDayPlan extends Equatable {
  const ChildDayPlan({required this.childName, required this.milestones});

  final String childName;

  final List<DayMilestone> milestones;

  @override
  List<Object?> get props => [childName, milestones];
}

class DayMilestone extends Equatable {
  const DayMilestone({
    required this.kind,
    required this.at,
    this.estimated = false,
    this.current = false,
    this.placeLabel,
  });

  final DayMilestoneKind kind;

  final DateTime at;

  final bool estimated;

  final bool current;

  final String? placeLabel;

  @override
  List<Object?> get props => [kind, at, estimated, current, placeLabel];
}
