import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

enum AssistantVansStatus { loading, ready, loadFailed }

class AssistantVansState extends Equatable {
  const AssistantVansState({
    this.status = AssistantVansStatus.loading,
    this.overview,
    this.failure,
  });

  final AssistantVansStatus status;

  final AssistantVansOverview? overview;

  final AssistantFailure? failure;

  @override
  List<Object?> get props => [status, overview, failure];
}
