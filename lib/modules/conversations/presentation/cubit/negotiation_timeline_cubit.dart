import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

class NegotiationTimelineCubit<R extends ServiceRequest>
    extends Cubit<NegotiationTimelineState<R>> {
  NegotiationTimelineCubit({
    required this.conversationToken,
    required this.findNegotiation,
  }) : super(NegotiationTimelineState<R>());

  final String conversationToken;

  final FindConversationNegotiation<R> findNegotiation;

  Future<void> load() async {
    if (state.negotiation == null) {
      emit(
        NegotiationTimelineState<R>(status: NegotiationTimelineStatus.loading),
      );
    }
    final result = await findNegotiation(conversationToken);
    if (isClosed) return;
    result.fold(showLoadFailure, showNegotiation);
  }

  void showLoadFailure(NegotiationFailure failure) {
    if (state.negotiation != null) return;
    emit(
      NegotiationTimelineState<R>(status: NegotiationTimelineStatus.loadFailed),
    );
  }

  void showNegotiation(ConversationNegotiation<R>? negotiation) {
    emit(
      negotiation == null
          ? NegotiationTimelineState<R>(status: NegotiationTimelineStatus.none)
          : NegotiationTimelineState<R>(
              status: NegotiationTimelineStatus.ready,
              negotiation: negotiation,
            ),
    );
  }
}
