import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';

sealed class AssistantHomeStatus extends Equatable {
  const AssistantHomeStatus();
}

class AssistantHomeNoVan extends AssistantHomeStatus {
  const AssistantHomeNoVan();

  @override
  List<Object?> get props => [];
}

class AssistantHomeInviteReceived extends AssistantHomeStatus {
  const AssistantHomeInviteReceived(this.invite);

  final AssistantInvite invite;

  @override
  List<Object?> get props => [invite];
}

class AssistantHomeBeforeRoute extends AssistantHomeStatus {
  const AssistantHomeBeforeRoute({required this.link, this.route});

  final AssistantVanLink link;
  final AssistantRouteSnapshot? route;

  @override
  List<Object?> get props => [link, route];
}

class AssistantHomeOnRouteBoarding extends AssistantHomeStatus {
  const AssistantHomeOnRouteBoarding({
    required this.link,
    required this.route,
    required this.stop,
  });

  final AssistantVanLink link;
  final AssistantRouteSnapshot route;
  final AssistantRouteStop stop;

  @override
  List<Object?> get props => [link, route, stop];
}

class AssistantHomeOnRouteDropOff extends AssistantHomeStatus {
  const AssistantHomeOnRouteDropOff({
    required this.link,
    required this.route,
    required this.stop,
  });

  final AssistantVanLink link;
  final AssistantRouteSnapshot route;
  final AssistantRouteStop stop;

  @override
  List<Object?> get props => [link, route, stop];
}

class AssistantHomeAccessPaused extends AssistantHomeStatus {
  const AssistantHomeAccessPaused({
    required this.link,
    this.otherActiveLinks = const [],
  });

  final AssistantVanLink link;
  final List<AssistantVanLink> otherActiveLinks;

  @override
  List<Object?> get props => [link, otherActiveLinks];
}
