import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';

class RequestDeclineCubit extends Cubit<RequestDeclineState> {
  RequestDeclineCubit({
    required this.requestToken,
    required this.declineServiceRequest,
  }) : super(const RequestDeclineState());

  final String requestToken;

  final DeclineServiceRequest declineServiceRequest;

  void changeReason(String reason) => emit(state.copyWith(reason: reason));

  Future<void> send() async {
    if (!state.canSend) return;
    emit(state.copyWith(isSending: true));
    final result = await declineServiceRequest(
      requestToken,
      reason: trimmedOrNull(state.reason),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(failure: failure),
        (request) => state.copyWith(declinedRequest: request),
      ),
    );
  }
}
