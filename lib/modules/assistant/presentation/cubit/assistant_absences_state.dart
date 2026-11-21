import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absences_overview.dart';

enum AssistantAbsencesStatus { loading, ready, loadFailed }

class AssistantAbsencesState extends Equatable {
  const AssistantAbsencesState({
    this.status = AssistantAbsencesStatus.loading,
    this.overview,
    this.failure,
  });

  final AssistantAbsencesStatus status;

  final AssistantAbsencesOverview? overview;

  final AssistantFailure? failure;

  @override
  List<Object?> get props => [status, overview, failure];
}
