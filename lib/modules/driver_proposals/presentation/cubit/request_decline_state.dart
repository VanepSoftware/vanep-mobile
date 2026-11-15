import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/decline_reason.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';

enum RequestDeclineOutcome { declined, outdated }

class RequestDeclineState extends Equatable {
  const RequestDeclineState({
    this.reason = '',
    this.isSending = false,
    this.failure,
    this.declinedRequest,
  });

  final String reason;

  final bool isSending;

  final NegotiationFailure? failure;

  final DriverServiceRequest? declinedRequest;

  bool get canSend =>
      !isSending && !isLongerThan(reason, declineReasonMaxLength);

  RequestDeclineState copyWith({
    String? reason,
    bool? isSending,
    NegotiationFailure? failure,
    DriverServiceRequest? declinedRequest,
  }) {
    return RequestDeclineState(
      reason: reason ?? this.reason,
      isSending: isSending ?? false,
      failure: failure,
      declinedRequest: declinedRequest,
    );
  }

  @override
  List<Object?> get props => [reason, isSending, failure, declinedRequest];
}
