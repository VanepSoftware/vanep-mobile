import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

enum DriverProposalStatus { initial, loading, ready, loadFailed, notFound }

class DriverProposalState extends Equatable {
  const DriverProposalState({
    this.status = DriverProposalStatus.initial,
    this.detail,
    this.actionFailure,
  });

  final DriverProposalStatus status;

  final DriverProposalDetail? detail;

  final NegotiationFailure? actionFailure;

  bool get isReady => status == DriverProposalStatus.ready && detail != null;

  @override
  List<Object?> get props => [status, detail, actionFailure];
}
