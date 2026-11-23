import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/get_recommended_drivers.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/search_drivers_by_place.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';

class DriverSearchCubit extends Cubit<DriverSearchState> {
  DriverSearchCubit({
    required this.searchDriversByPlace,
    this.getRecommendedDrivers,
    this.findMyPersonalAddress,
    this.findMyDependents,
  }) : super(const DriverSearchState());

  final SearchDriversByPlace searchDriversByPlace;
  final GetRecommendedDrivers? getRecommendedDrivers;
  final FindMyPersonalAddress? findMyPersonalAddress;
  final FindMyDependents? findMyDependents;

  Future<void> loadRecommended() async {
    final getRec = getRecommendedDrivers;
    if (getRec == null) return;

    emit(
      state.copyWith(
        status: DriverSearchStatus.searching,
        clearFailure: true,
      ),
    );

    final recFuture = getRec();
    final contextFuture = _loadClientContext();

    final result = await recFuture;
    final contextData = await contextFuture;
    if (isClosed) return;

    final dependents = contextData.dependents ?? state.dependents;

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DriverSearchStatus.failed,
          failure: failure,
          isShowingRecommended: true,
          personalAddress: contextData.address,
          dependents: dependents,
        ),
        (page) {
          return state.copyWith(
            status: DriverSearchStatus.loaded,
            results: page.drivers,
            recommendedResults: page.drivers,
            isShowingRecommended: true,
            clearPlaceId: true,
            clearSearchedLabel: true,
            clearFailure: true,
            nextPage: 1,
            hasMore: !page.isLast,
            personalAddress: contextData.address,
            dependents: dependents,
          );
        },
      ),
    );
  }

  Future<({PersonalAddress? address, List<Dependent>? dependents})>
  _loadClientContext() async {
    PersonalAddress? address;
    List<Dependent>? dependents;

    final addressFuture = findMyPersonalAddress?.call();
    final dependentsFuture = findMyDependents?.call();

    if (addressFuture != null) {
      final addressResult = await addressFuture;
      if (addressResult case Ok(:final value)) {
        address = value;
      }
    }
    if (dependentsFuture != null) {
      final depResult = await dependentsFuture;
      if (depResult case Ok(:final value)) {
        dependents = value;
      }
    }
    return (address: address, dependents: dependents);
  }

  void clearSearch() {
    if (state.recommendedResults.isNotEmpty) {
      emit(
        state.copyWith(
          status: DriverSearchStatus.loaded,
          results: state.recommendedResults,
          isShowingRecommended: true,
          clearPlaceId: true,
          clearSearchedLabel: true,
          clearFailure: true,
          clearOriginLabel: true,
          clearDestinationLabel: true,
          selectedDependentTokens: const {},
          routeSwapped: false,
          hasMore: false,
          nextPage: 0,
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
      state.copyWith(
        status: DriverSearchStatus.searching,
        searchedLabel: label,
        placeId: placeId,
        isShowingRecommended: false,
        clearFailure: true,
      ),
    );
    final result = await searchDriversByPlace(
      placeId,
      sessionToken: sessionToken,
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DriverSearchStatus.failed,
          failure: failure,
          searchedLabel: label,
          placeId: placeId,
          isShowingRecommended: false,
        ),
        (page) {
          return state.copyWith(
            status: DriverSearchStatus.loaded,
            results: page.drivers,
            searchedLabel: label,
            placeId: placeId,
            nextPage: 1,
            hasMore: !page.isLast,
            isShowingRecommended: false,
            clearFailure: true,
          );
        },
      ),
    );
  }

  Future<void> searchFromRoute({
    required bool isDestination,
    required String placeId,
    required String label,
    String? sessionToken,
  }) async {
    final editingOrigin = isDestination == state.routeSwapped;
    emit(
      state.copyWith(
        originLabel: editingOrigin ? label : state.originLabel,
        destinationLabel: editingOrigin ? state.destinationLabel : label,
      ),
    );
    await searchPlace(placeId, label: label, sessionToken: sessionToken);
  }

  void toggleDependent(String token) {
    final next = Set<String>.of(state.selectedDependentTokens);
    if (next.contains(token)) {
      if (next.length > 1) {
        next.remove(token);
      }
    } else {
      next.add(token);
    }
    emit(state.copyWith(selectedDependentTokens: next));
  }

  void setSortOrder(DriverSearchSortOrder order) {
    emit(state.copyWith(sortOrder: order));
  }

  void swapRoute() {
    emit(state.copyWith(routeSwapped: !state.routeSwapped));
  }

  void useProfileOrigin() {
    final defaultOrigin = state.defaultOriginText;
    if (defaultOrigin == null) return;
    emit(state.copyWith(originLabel: defaultOrigin));
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    final placeId = state.placeId;
    if (placeId == null) return;

    final loading = state.copyWith(
      status: DriverSearchStatus.loadingMore,
      clearFailure: true,
    );
    emit(loading);

    final result = await searchDriversByPlace(placeId, page: loading.nextPage);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => loading.copyWith(
          status: DriverSearchStatus.loadMoreFailed,
          failure: failure,
        ),
        (page) {
          return loading.copyWith(
            status: DriverSearchStatus.loaded,
            results: [...loading.results, ...page.drivers],
            nextPage: loading.nextPage + 1,
            hasMore: !page.isLast,
            clearFailure: true,
          );
        },
      ),
    );
  }

  Future<void> retryLoadMore() async {
    if (state.status != DriverSearchStatus.loadMoreFailed) return;
    emit(state.copyWith(status: DriverSearchStatus.loaded));
    await loadMore();
  }
}
