import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';

class DriverServiceRequestCubit extends Cubit<DriverServiceRequestState> {
  DriverServiceRequestCubit({
    required this.requestToken,
    required this.findServiceRequest,
  }) : super(const DriverServiceRequestState());

  final String requestToken;

  final FindDriverServiceRequest findServiceRequest;

  Future<void> load() async {
    if (!state.isReady) {
      emit(
        const DriverServiceRequestState(
          status: DriverServiceRequestStatus.loading,
        ),
      );
    }
    final result = await findServiceRequest(requestToken);
    if (isClosed) return;
    result.fold(
      showLoadFailure,
      (request) => emit(
        DriverServiceRequestState(
          status: DriverServiceRequestStatus.ready,
          request: request,
        ),
      ),
    );
  }

  void showLoadFailure(NegotiationFailure failure) {
    if (failure is NegotiationNotFoundFailure) {
      emit(
        const DriverServiceRequestState(
          status: DriverServiceRequestStatus.notFound,
        ),
      );
    } else if (state.isReady) {
      emit(
        DriverServiceRequestState(
          status: state.status,
          request: state.request,
          actionFailure: failure,
        ),
      );
    } else {
      emit(
        const DriverServiceRequestState(
          status: DriverServiceRequestStatus.loadFailed,
        ),
      );
    }
  }
}
