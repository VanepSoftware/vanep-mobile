import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_search_result.dart';
import '../../domain/failures/driver_search_failure.dart';

enum DriverSearchStatus { initial, searching, loaded, failed }

class DriverSearchState extends Equatable {
  const DriverSearchState({
    this.status = DriverSearchStatus.initial,
    this.results = const [],
    this.failure,
    this.searchedLabel,
  });

  final DriverSearchStatus status;

  final List<DriverSearchResult> results;

  final DriverSearchFailure? failure;

  final String? searchedLabel;

  bool get hasNoResults =>
      status == DriverSearchStatus.loaded && results.isEmpty;

  @override
  List<Object?> get props => [status, results, failure, searchedLabel];
}
