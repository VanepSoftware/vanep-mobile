import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_negotiations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class DriverNegotiationsCubit extends Cubit<DriverNegotiationsState> {
  DriverNegotiationsCubit({
    required this.listServiceRequests,
    this.clock = DateTime.now,
  }) : super(const DriverNegotiationsState());

  final ListDriverServiceRequests listServiceRequests;

  final DateTime Function() clock;

  Future<void> load() async {
    if (state.negotiations == null) {
      emit(
        DriverNegotiationsState(
          status: DriverNegotiationsStatus.loading,
          segment: state.segment,
        ),
      );
    }
    final result = await listServiceRequests(
      statuses: openServiceRequestStatuses,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(value: final firstPage):
        emit(
          DriverNegotiationsState(
            status: DriverNegotiationsStatus.ready,
            negotiations: DriverNegotiations.fromFirstPage(
              firstPage,
              loadedAt: clock(),
            ),
            segment: state.segment,
          ),
        );
      case Err() when state.negotiations == null:
        emit(
          DriverNegotiationsState(
            status: DriverNegotiationsStatus.loadFailed,
            segment: state.segment,
          ),
        );
      case Err(error: final failure):
        emit(state.copyWith(actionFailure: failure));
    }
  }

  Future<void> loadMore() async {
    final negotiations = state.negotiations;
    if (negotiations == null || !negotiations.hasMore || state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = negotiations.page + 1;
    final result = await listServiceRequests(
      statuses: openServiceRequestStatuses,
      page: nextPage,
    );
    if (isClosed || !identical(state.negotiations, negotiations)) return;
    emit(
      result.fold(
        (failure) =>
            state.copyWith(isLoadingMore: false, actionFailure: failure),
        (page) => state.copyWith(
          negotiations: negotiations.withNextPage(page, page: nextPage),
          isLoadingMore: false,
        ),
      ),
    );
  }

  void selectSegment(DriverProposalsSegment segment) {
    emit(state.copyWith(segment: segment));
  }
}
