import 'package:equatable/equatable.dart';

import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';

enum DependentsStatus { initial, loading, ready, loadFailed, changingDefault }

class DependentsState extends Equatable {
  const DependentsState({
    this.status = DependentsStatus.initial,
    this.dependents = const [],
    this.failure,
  });

  final DependentsStatus status;

  final List<Dependent> dependents;

  final DependentFailure? failure;

  bool get isLoading => status == DependentsStatus.loading;

  bool get hasLoadFailed => status == DependentsStatus.loadFailed;

  bool get isEmpty =>
      status == DependentsStatus.ready && dependents.isEmpty;

  bool get canChooseDefault => dependents.length > 1;

  String? get defaultToken {
    for (final dependent in dependents) {
      if (dependent.isDefault) return dependent.token;
    }
    return null;
  }

  DependentsState copyWith({
    DependentsStatus? status,
    List<Dependent>? dependents,
    DependentFailure? failure,
    bool clearFailure = false,
  }) {
    return DependentsState(
      status: status ?? this.status,
      dependents: dependents ?? this.dependents,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, dependents, failure];
}
