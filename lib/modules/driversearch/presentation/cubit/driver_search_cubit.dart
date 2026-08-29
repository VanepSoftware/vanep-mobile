import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_drivers_by_place.dart';
import 'driver_search_state.dart';

class DriverSearchCubit extends Cubit<DriverSearchState> {
  DriverSearchCubit({required this.searchDriversByPlace})
    : super(const DriverSearchState());

  final SearchDriversByPlace searchDriversByPlace;

  Future<void> searchPlace(
    String placeId, {
    required String label,
    String? sessionToken,
  }) async {
    emit(
      DriverSearchState(
        status: DriverSearchStatus.searching,
        searchedLabel: label,
        placeId: placeId,
      ),
    );
    final result = await searchDriversByPlace(
      placeId,
      sessionToken: sessionToken,
    );
    emit(
      result.fold(
        (failure) => DriverSearchState(
          status: DriverSearchStatus.failed,
          failure: failure,
          searchedLabel: label,
          placeId: placeId,
        ),
        (page) => DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: page.drivers,
          searchedLabel: label,
          placeId: placeId,
          nextPage: 1,
          hasMore: !page.isLast,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    final placeId = state.placeId;
    if (placeId == null) return;

    final loading = state.copyWith(status: DriverSearchStatus.loadingMore);
    emit(loading);

    final result = await searchDriversByPlace(placeId, page: loading.nextPage);
    emit(
      result.fold(
        (failure) => loading.copyWith(
          status: DriverSearchStatus.loaded,
          failure: failure,
        ),
        (page) => loading.copyWith(
          status: DriverSearchStatus.loaded,
          results: [...loading.results, ...page.drivers],
          nextPage: loading.nextPage + 1,
          hasMore: !page.isLast,
        ),
      ),
    );
  }
}
