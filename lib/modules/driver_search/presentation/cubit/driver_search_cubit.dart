import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_search/domain/usecases/get_recommended_drivers.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/search_drivers_by_place.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';

class DriverSearchCubit extends Cubit<DriverSearchState> {
  DriverSearchCubit({
    required this.searchDriversByPlace,
    this.getRecommendedDrivers,
  }) : super(const DriverSearchState());

  final SearchDriversByPlace searchDriversByPlace;
  final GetRecommendedDrivers? getRecommendedDrivers;

  Future<void> loadRecommended() async {
    final getRec = getRecommendedDrivers;
    if (getRec == null) return;

    emit(state.copyWith(status: DriverSearchStatus.searching));
    final result = await getRec();
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DriverSearchStatus.failed,
          failure: failure,
          isShowingRecommended: true,
        ),
        (page) => state.copyWith(
          status: DriverSearchStatus.loaded,
          results: page.drivers,
          recommendedResults: page.drivers,
          isShowingRecommended: true,
          placeId: null,
          searchedLabel: null,
          nextPage: 1,
          hasMore: !page.isLast,
        ),
      ),
    );
  }

  void clearSearch() {
    if (state.recommendedResults.isNotEmpty) {
      emit(
        DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: state.recommendedResults,
          recommendedResults: state.recommendedResults,
          isShowingRecommended: true,
        ),
      );
    } else {
      loadRecommended();
    }
  }

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
        isShowingRecommended: false,
        recommendedResults: state.recommendedResults,
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
          isShowingRecommended: false,
          recommendedResults: state.recommendedResults,
        ),
        (page) => DriverSearchState(
          status: DriverSearchStatus.loaded,
          results: page.drivers,
          searchedLabel: label,
          placeId: placeId,
          nextPage: 1,
          hasMore: !page.isLast,
          isShowingRecommended: false,
          recommendedResults: state.recommendedResults,
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
          status: DriverSearchStatus.loadMoreFailed,
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

  Future<void> retryLoadMore() async {
    if (state.status != DriverSearchStatus.loadMoreFailed) return;
    emit(state.copyWith(status: DriverSearchStatus.loaded));
    await loadMore();
  }
}
