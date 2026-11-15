import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_home/domain/value_objects/day_event.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

sealed class TodaySection extends Equatable {
  const TodaySection();

  bool get hasLinkedVan;

  @override
  List<Object?> get props => const [];
}

enum FirstStep { account, address, dependents }

final class FirstStepsSection extends TodaySection {
  const FirstStepsSection({
    required this.hasAddress,
    required this.hasDependents,
  });

  static const totalSteps = 3;

  final bool hasAddress;

  final bool hasDependents;

  @override
  bool get hasLinkedVan => false;

  bool isStepDone(FirstStep step) => switch (step) {
    FirstStep.account => true,
    FirstStep.address => hasAddress,
    FirstStep.dependents => hasDependents,
  };

  int get completedSteps => FirstStep.values.where(isStepDone).length;

  FirstStep? get currentStep {
    for (final step in FirstStep.values) {
      if (!isStepDone(step)) return step;
    }
    return null;
  }

  bool get isComplete => currentStep == null;

  @override
  List<Object?> get props => [hasAddress, hasDependents];
}

final class NoLinkedVanSection extends TodaySection {
  const NoLinkedVanSection();

  @override
  bool get hasLinkedVan => false;
}

final class NegotiatingSection extends TodaySection {
  const NegotiatingSection({
    required this.childNames,
    required this.openNegotiations,
  });

  final List<String> childNames;

  final int openNegotiations;

  @override
  bool get hasLinkedVan => false;

  @override
  List<Object?> get props => [childNames, openNegotiations];
}

int compareVansForToday(VanDay first, VanDay second) {
  final firstIsLive = first.live != null;
  if (firstIsLive != (second.live != null)) return firstIsLive ? -1 : 1;
  return first.departureAt.compareTo(second.departureAt);
}

final class VanDaySection extends TodaySection {
  const VanDaySection({
    required this.vans,
    this.childrenWithoutRoute = const [],
    this.childDay,
  });

  final List<VanDay> vans;

  final List<ChildWithoutRoute> childrenWithoutRoute;

  final ChildDayPlan? childDay;

  @override
  bool get hasLinkedVan => true;

  VanDay? get liveVan {
    for (final van in vans) {
      if (van.live != null) return van;
    }
    return null;
  }

  bool get isVanApproaching => liveVan?.live?.approaching ?? false;

  List<VanDay> get orderedVans => [...vans]..sort(compareVansForToday);

  VanDay? get expandedVan => orderedVans.firstOrNull;

  List<VanDay> get collapsedVans => orderedVans.skip(1).toList();

  @override
  List<Object?> get props => [vans, childrenWithoutRoute, childDay];
}

final class ArrivedSection extends TodaySection {
  const ArrivedSection({
    required this.childName,
    required this.schoolName,
    required this.confirmedAt,
    required this.schoolDepartureAt,
    required this.events,
    this.returnPlaceLabel,
  });

  final String childName;

  final String schoolName;

  final DateTime confirmedAt;

  final DateTime schoolDepartureAt;

  final String? returnPlaceLabel;

  final List<DayEvent> events;

  @override
  bool get hasLinkedVan => true;

  @override
  List<Object?> get props => [
    childName,
    schoolName,
    confirmedAt,
    schoolDepartureAt,
    returnPlaceLabel,
    events,
  ];
}

final class NoRouteTodaySection extends TodaySection {
  const NoRouteTodaySection({required this.nextRouteAt, required this.week});

  final DateTime nextRouteAt;

  final List<WeekDayPlan> week;

  @override
  bool get hasLinkedVan => true;

  WeekDayPlan? get firstDayWithoutReturn {
    for (final day in week) {
      if (day.going && !day.returning) return day;
    }
    return null;
  }

  @override
  List<Object?> get props => [nextRouteAt, week];
}

class WeekDayPlan extends Equatable {
  const WeekDayPlan({
    required this.date,
    required this.going,
    required this.returning,
  });

  final DateTime date;

  final bool going;

  final bool returning;

  @override
  List<Object?> get props => [date, going, returning];
}

enum NoRouteReason { goesWithGuardian, noVanYet }

class ChildWithoutRoute extends Equatable {
  const ChildWithoutRoute({required this.name, required this.reason});

  final String name;

  final NoRouteReason reason;

  @override
  List<Object?> get props => [name, reason];
}
