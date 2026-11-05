import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

class AssistantVanSummary extends Equatable {
  const AssistantVanSummary({
    required this.van,
    required this.departureMinutes,
    required this.studentCount,
    required this.hasRouteToday,
  });

  final AssistantVan van;

  final int departureMinutes;

  final int studentCount;

  final bool hasRouteToday;

  @override
  List<Object?> get props => [
    van,
    departureMinutes,
    studentCount,
    hasRouteToday,
  ];
}

class AssistantVansOverview extends Equatable {
  const AssistantVansOverview({
    this.pendingInvite,
    this.activeVans = const [],
    this.formerVanCount = 0,
  });

  final AssistantInvite? pendingInvite;

  final List<AssistantVanSummary> activeVans;

  final int formerVanCount;

  bool get isEmpty => pendingInvite == null && activeVans.isEmpty;

  @override
  List<Object?> get props => [pendingInvite, activeVans, formerVanCount];
}
