import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_request_seats.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';

class DriverServiceRequestCubit extends Cubit<DriverServiceRequestState> {
  DriverServiceRequestCubit({
    required this.requestToken,
    required this.findServiceRequest,
    required this.loadRequestSeats,
  }) : super(const DriverServiceRequestState());

  final String requestToken;

  final FindDriverServiceRequest findServiceRequest;

  final LoadRequestSeats loadRequestSeats;

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
    await result.fold((failure) async => showLoadFailure(failure), showRequest);
  }

  Future<void> showRequest(DriverServiceRequest request) async {
    emit(
      DriverServiceRequestState(
        status: DriverServiceRequestStatus.ready,
        request: request,
        seats: state.seats,
      ),
    );
    if (!state.canAnswer) return;
    final seats = await loadRequestSeats(request);
    if (isClosed) return;
    emit(
      DriverServiceRequestState(
        status: DriverServiceRequestStatus.ready,
        request: request,
        seats: seats,
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
          seats: state.seats,
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
