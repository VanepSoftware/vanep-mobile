import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_search_result.dart';
import '../../domain/failures/driver_search_failure.dart';

enum DriverSearchStatus { initial, searching, loaded, loadingMore, failed }

class DriverSearchState extends Equatable {
  const DriverSearchState({
    this.status = DriverSearchStatus.initial,
    this.results = const [],
    this.failure,
    this.searchedLabel,
    this.placeId,
    this.nextPage = 0,
    this.hasMore = false,
  });

  final DriverSearchStatus status;

  final List<DriverSearchResult> results;

  final DriverSearchFailure? failure;

  final String? searchedLabel;

  final String? placeId;

  final int nextPage;

  final bool hasMore;

  bool get hasNoResults =>
      status == DriverSearchStatus.loaded && results.isEmpty;

  bool get canLoadMore =>
      hasMore && status == DriverSearchStatus.loaded && placeId != null;

  DriverSearchState copyWith({
    DriverSearchStatus? status,
    List<DriverSearchResult>? results,
    DriverSearchFailure? failure,
    String? searchedLabel,
    String? placeId,
    int? nextPage,
    bool? hasMore,
  }) {
    return DriverSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      failure: failure,
      searchedLabel: searchedLabel ?? this.searchedLabel,
      placeId: placeId ?? this.placeId,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    results,
    failure,
    searchedLabel,
    placeId,
    nextPage,
    hasMore,
  ];
}
