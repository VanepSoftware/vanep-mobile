import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

enum AssistantLinkStatus {
  pending,
  active,
  inactive;

  static AssistantLinkStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    return switch (raw.trim().toUpperCase()) {
      'PENDING' => AssistantLinkStatus.pending,
      'ACTIVE' => AssistantLinkStatus.active,
      'INACTIVE' => AssistantLinkStatus.inactive,
      _ => null,
    };
  }

  static String toApi(AssistantLinkStatus status) {
    return switch (status) {
      AssistantLinkStatus.pending => 'PENDING',
      AssistantLinkStatus.active => 'ACTIVE',
      AssistantLinkStatus.inactive => 'INACTIVE',
    };
  }
}

class AssistantVanLink extends Equatable {
  const AssistantVanLink({
    required this.van,
    required this.status,
    this.statusChangedAt,
  });

  final AssistantVan van;
  final AssistantLinkStatus status;
  final DateTime? statusChangedAt;

  bool get isActive => status == AssistantLinkStatus.active;

  @override
  List<Object?> get props => [van, status, statusChangedAt];
}

class AssistantHomeOverview extends Equatable {
  const AssistantHomeOverview({this.links = const [], this.pendingInvite});

  final List<AssistantVanLink> links;
  final AssistantInvite? pendingInvite;

  @override
  List<Object?> get props => [links, pendingInvite];
}
