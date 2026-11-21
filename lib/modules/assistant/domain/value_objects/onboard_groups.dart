import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';

class OnboardGroups extends Equatable {
  const OnboardGroups({
    this.onBoard = const [],
    this.awaiting = const [],
    this.didNotBoard = const [],
    this.notGoingToday = const [],
  });

  final List<AssistantRoutePassenger> onBoard;
  final List<AssistantRoutePassenger> awaiting;
  final List<AssistantRoutePassenger> didNotBoard;
  final List<AssistantRoutePassenger> notGoingToday;

  @override
  List<Object?> get props => [onBoard, awaiting, didNotBoard, notGoingToday];
}
