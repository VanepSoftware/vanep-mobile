import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';

enum DependentDetailStatus { loading, loaded, loadFailed }

class DependentDetailState extends Equatable {
  const DependentDetailState({
    this.status = DependentDetailStatus.loading,
    this.week,
  });

  final DependentDetailStatus status;

  final SchoolWeek? week;

  bool get isLoading => status == DependentDetailStatus.loading;

  bool get hasLoadFailed => status == DependentDetailStatus.loadFailed;

  @override
  List<Object?> get props => [status, week];
}
