import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';

enum DependentsStatus { initial, loading, ready, loadFailed, changingDefault }

class DependentsState extends Equatable {
  const DependentsState({
    this.status = DependentsStatus.initial,
    this.dependents = const [],
    this.readinessByToken,
    this.failure,
  });

  final DependentsStatus status;

  final List<Dependent> dependents;

  final Map<String, Set<ContractReadinessField>>? readinessByToken;

  final DependentFailure? failure;

  bool get isLoading => status == DependentsStatus.loading;

  bool get isChangingDefault => status == DependentsStatus.changingDefault;

  bool get keepsListVisibleWhileReloading =>
      status == DependentsStatus.ready || isChangingDefault;

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

  Dependent? dependentOf(String token) {
    for (final dependent in dependents) {
      if (dependent.token == token) return dependent;
    }
    return null;
  }

  Set<ContractReadinessField>? gapsOf(String token) => readinessByToken?[token];

  bool isIncomplete(String token) => gapsOf(token)?.isNotEmpty ?? false;

  DependentsState copyWith({
    DependentsStatus? status,
    List<Dependent>? dependents,
    Map<String, Set<ContractReadinessField>>? readinessByToken,
    bool clearReadiness = false,
    DependentFailure? failure,
    bool clearFailure = false,
  }) {
    return DependentsState(
      status: status ?? this.status,
      dependents: dependents ?? this.dependents,
      readinessByToken: clearReadiness
          ? null
          : readinessByToken ?? this.readinessByToken,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, dependents, readinessByToken, failure];
}
