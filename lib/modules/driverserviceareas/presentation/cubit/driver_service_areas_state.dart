import 'package:equatable/equatable.dart';

import '../../domain/entities/service_area.dart';
import '../../domain/entities/service_area_draft.dart';
import '../../domain/failures/service_area_failure.dart';
import '../../domain/usecases/replace_my_service_areas.dart';

enum DriverServiceAreasStatus { initial, loading, ready, saving, saved }

class DriverServiceAreasState extends Equatable {
  const DriverServiceAreasState({
    this.status = DriverServiceAreasStatus.initial,
    this.saved = const [],
    this.drafts = const [],
    this.failure,
  });

  final DriverServiceAreasStatus status;

  final List<ServiceArea> saved;

  final List<ServiceAreaDraft> drafts;

  final ServiceAreaFailure? failure;

  bool get canAddMore => drafts.length < maxServiceAreas;

  bool get isEmpty => drafts.isEmpty;

  DriverServiceAreasState copyWith({
    DriverServiceAreasStatus? status,
    List<ServiceArea>? saved,
    List<ServiceAreaDraft>? drafts,
    ServiceAreaFailure? failure,
    bool clearFailure = false,
  }) {
    return DriverServiceAreasState(
      status: status ?? this.status,
      saved: saved ?? this.saved,
      drafts: drafts ?? this.drafts,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, saved, drafts, failure];
}
