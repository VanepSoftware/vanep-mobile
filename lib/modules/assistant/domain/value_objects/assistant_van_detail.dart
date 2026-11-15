import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';

const assistantVanDetailStopPreviewCount = 4;

class AssistantVanDetail extends Equatable {
  const AssistantVanDetail({
    required this.van,
    required this.linkStatus,
    required this.studentsCount,
    this.departureAt,
    this.driverPhone,
    this.stops = const [],
  });

  final AssistantVan van;
  final AssistantLinkStatus linkStatus;
  final int studentsCount;
  final DateTime? departureAt;
  final String? driverPhone;
  final List<AssistantRouteStop> stops;

  List<AssistantRouteStop> get previewStops =>
      stops.take(assistantVanDetailStopPreviewCount).toList();

  @override
  List<Object?> get props => [
    van,
    linkStatus,
    studentsCount,
    departureAt,
    driverPhone,
    stops,
  ];
}
