import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_negotiations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

enum DriverNegotiationsStatus { initial, loading, ready, loadFailed }

enum DriverProposalsSegment { negotiations, contracts }

class DriverNegotiationsState extends Equatable {
  const DriverNegotiationsState({
    this.status = DriverNegotiationsStatus.initial,
    this.negotiations,
    this.segment = DriverProposalsSegment.negotiations,
    this.isLoadingMore = false,
    this.actionFailure,
  });

  final DriverNegotiationsStatus status;

  final DriverNegotiations? negotiations;

  final DriverProposalsSegment segment;

  final bool isLoadingMore;

  final NegotiationFailure? actionFailure;

  bool get hasLoadFailed => status == DriverNegotiationsStatus.loadFailed;

  DriverNegotiationsState copyWith({
    DriverNegotiations? negotiations,
    DriverProposalsSegment? segment,
    bool? isLoadingMore,
    NegotiationFailure? actionFailure,
  }) {
    return DriverNegotiationsState(
      status: status,
      negotiations: negotiations ?? this.negotiations,
      segment: segment ?? this.segment,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionFailure: actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    negotiations,
    segment,
    isLoadingMore,
    actionFailure,
  ];
}
