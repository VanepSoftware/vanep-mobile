import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/formatters/postal_address_display.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';

enum DriverSearchStatus {
  initial,
  searching,
  loaded,
  loadingMore,
  loadMoreFailed,
  failed,
}

enum DriverSearchSortOrder {
  nearest,
  highestRating,
  lowestPrice,
  mostExperienced,
}

class DriverSearchState extends Equatable {
  const DriverSearchState({
    this.status = DriverSearchStatus.initial,
    this.results = const [],
    this.failure,
    this.searchedLabel,
    this.placeId,
    this.nextPage = 0,
    this.hasMore = false,
    this.isShowingRecommended = false,
    this.recommendedResults = const [],
    this.personalAddress,
    this.dependents = const [],
    this.selectedDependentTokens = const {},
    this.sortOrder = DriverSearchSortOrder.nearest,
    this.originLabel,
    this.destinationLabel,
    this.routeSwapped = false,
  });

  final DriverSearchStatus status;

  final List<DriverSearchResult> results;

  final DriverSearchFailure? failure;

  final String? searchedLabel;

  final String? placeId;

  final int nextPage;

  final bool hasMore;

  final bool isShowingRecommended;

  final List<DriverSearchResult> recommendedResults;

  final PersonalAddress? personalAddress;

  final List<Dependent> dependents;

  final Set<String> selectedDependentTokens;

  final DriverSearchSortOrder sortOrder;

  final String? originLabel;

  final String? destinationLabel;

  final bool routeSwapped;

  bool get hasNoResults =>
      status == DriverSearchStatus.loaded && displayedResults.isEmpty;

  bool get canLoadMore =>
      hasMore && status == DriverSearchStatus.loaded && placeId != null;

  List<DriverSearchResult> get displayedResults {
    final available = results.where((driver) => driver.available).toList();
    final unavailable = results.where((driver) => !driver.available).toList();

    final int Function(DriverSearchResult, DriverSearchResult)? comparator =
        switch (sortOrder) {
          DriverSearchSortOrder.nearest => null,
          DriverSearchSortOrder.highestRating => (a, b) =>
              (b.rating ?? -1).compareTo(a.rating ?? -1),
          DriverSearchSortOrder.lowestPrice => (a, b) =>
              (a.basePrice ?? double.infinity).compareTo(
                b.basePrice ?? double.infinity,
              ),
          DriverSearchSortOrder.mostExperienced => (a, b) =>
              (b.experienceYears ?? -1).compareTo(a.experienceYears ?? -1),
        };

    if (comparator != null) {
      available.sort(comparator);
      unavailable.sort(comparator);
    }
    return [...available, ...unavailable];
  }

  String? get defaultOriginText {
    final address = personalAddress;
    if (address == null) return null;
    final streetLine = joinPostalStreetLine(
      street: address.street.trim(),
      number: address.number,
    ).trim();
    final neighborhood = address.neighborhood?.trim() ?? '';
    final city = address.cityName.trim();
    final parts = <String>[
      if (streetLine.isNotEmpty) streetLine,
      if (neighborhood.isNotEmpty &&
          neighborhood.toLowerCase() != streetLine.toLowerCase())
        neighborhood,
      if (city.isNotEmpty) city,
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String? get defaultDestinationText {
    for (final dependent in dependents) {
      if (selectedDependentTokens.isEmpty ||
          selectedDependentTokens.contains(dependent.token)) {
        final school = dependent.school?.name.trim();
        if (school != null && school.isNotEmpty) return school;
      }
    }
    return null;
  }

  String? get effectiveOriginLabel {
    return routeSwapped ? destinationLabel : originLabel;
  }

  String? get effectiveDestinationLabel {
    return routeSwapped ? originLabel : destinationLabel;
  }

  DriverSearchState copyWith({
    DriverSearchStatus? status,
    List<DriverSearchResult>? results,
    DriverSearchFailure? failure,
    bool clearFailure = false,
    String? searchedLabel,
    bool clearSearchedLabel = false,
    String? placeId,
    bool clearPlaceId = false,
    int? nextPage,
    bool? hasMore,
    bool? isShowingRecommended,
    List<DriverSearchResult>? recommendedResults,
    PersonalAddress? personalAddress,
    List<Dependent>? dependents,
    Set<String>? selectedDependentTokens,
    DriverSearchSortOrder? sortOrder,
    String? originLabel,
    bool clearOriginLabel = false,
    String? destinationLabel,
    bool clearDestinationLabel = false,
    bool? routeSwapped,
  }) {
    return DriverSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      failure: clearFailure ? null : (failure ?? this.failure),
      searchedLabel: clearSearchedLabel
          ? null
          : (searchedLabel ?? this.searchedLabel),
      placeId: clearPlaceId ? null : (placeId ?? this.placeId),
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isShowingRecommended: isShowingRecommended ?? this.isShowingRecommended,
      recommendedResults: recommendedResults ?? this.recommendedResults,
      personalAddress: personalAddress ?? this.personalAddress,
      dependents: dependents ?? this.dependents,
      selectedDependentTokens:
          selectedDependentTokens ?? this.selectedDependentTokens,
      sortOrder: sortOrder ?? this.sortOrder,
      originLabel: clearOriginLabel ? null : (originLabel ?? this.originLabel),
      destinationLabel: clearDestinationLabel
          ? null
          : (destinationLabel ?? this.destinationLabel),
      routeSwapped: routeSwapped ?? this.routeSwapped,
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
    isShowingRecommended,
    recommendedResults,
    personalAddress,
    dependents,
    selectedDependentTokens,
    sortOrder,
    originLabel,
    destinationLabel,
    routeSwapped,
  ];
}
