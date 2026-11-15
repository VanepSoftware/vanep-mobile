import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

enum AssistantHomeLoadStatus { loading, ready, loadFailed }

class AssistantHomeState extends Equatable {
  const AssistantHomeState({
    this.status = AssistantHomeLoadStatus.loading,
    this.overview,
    this.selectedVanToken,
    this.route,
    this.failure,
    this.actionFailure,
    this.lastConfirmation,
    this.isConfirming = false,
    this.isPresentInVan = false,
  });

  final AssistantHomeLoadStatus status;
  final AssistantHomeOverview? overview;
  final String? selectedVanToken;
  final AssistantRouteSnapshot? route;
  final AssistantFailure? failure;
  final AssistantFailure? actionFailure;
  final StopConfirmation? lastConfirmation;
  final bool isConfirming;
  final bool isPresentInVan;

  AssistantHomeStatus get homeStatus => deriveAssistantHomeStatus(
    links: overview?.links ?? const [],
    pendingInvite: overview?.pendingInvite,
    selectedVanToken: selectedVanToken,
    route: route,
  );

  AssistantHomeState copyWith({
    AssistantRouteSnapshot? route,
    AssistantFailure? actionFailure,
    StopConfirmation? lastConfirmation,
    bool? isConfirming,
    bool? isPresentInVan,
  }) {
    return AssistantHomeState(
      status: status,
      overview: overview,
      selectedVanToken: selectedVanToken,
      route: route ?? this.route,
      failure: failure,
      actionFailure: actionFailure ?? this.actionFailure,
      lastConfirmation: lastConfirmation ?? this.lastConfirmation,
      isConfirming: isConfirming ?? this.isConfirming,
      isPresentInVan: isPresentInVan ?? this.isPresentInVan,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    selectedVanToken,
    route,
    failure,
    actionFailure,
    lastConfirmation,
    isConfirming,
    isPresentInVan,
  ];
}
