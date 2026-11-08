import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

enum NegotiationTimelineStatus { initial, loading, ready, none, loadFailed }

class NegotiationTimelineState<R extends ServiceRequest> extends Equatable {
  const NegotiationTimelineState({
    this.status = NegotiationTimelineStatus.initial,
    this.negotiation,
  });

  final NegotiationTimelineStatus status;

  final ConversationNegotiation<R>? negotiation;

  bool get hasLoadFailed => status == NegotiationTimelineStatus.loadFailed;

  @override
  List<Object?> get props => [status, negotiation];
}
