import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

class AssistantFormerLink extends Equatable {
  const AssistantFormerLink({
    required this.van,
    required this.joinedAt,
    required this.endedAt,
  });

  final AssistantVan van;
  final DateTime joinedAt;
  final DateTime endedAt;

  @override
  List<Object?> get props => [van, joinedAt, endedAt];
}

List<AssistantFormerLink> latestEndedFirst(List<AssistantFormerLink> links) =>
    [...links]
      ..sort((first, second) => second.endedAt.compareTo(first.endedAt));
