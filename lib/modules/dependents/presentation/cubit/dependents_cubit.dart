import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/remove_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/set_default_dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';

class DependentsCubit extends Cubit<DependentsState> {
  DependentsCubit({
    required this.findMyDependents,
    required this.setDefaultDependent,
    required this.deleteDependent,
    required this.findContractReadiness,
  }) : super(const DependentsState());

  final FindMyDependents findMyDependents;
  final SetDefaultDependent setDefaultDependent;
  final RemoveDependent deleteDependent;
  final FindContractReadiness findContractReadiness;

  Future<void> loadDependents() async {
    if (!state.keepsListVisibleWhileReloading) {
      emit(state.copyWith(status: DependentsStatus.loading, clearFailure: true));
    }
    final result = await findMyDependents();
    switch (result) {
      case Err(:final error):
        emit(
          state.copyWith(status: DependentsStatus.loadFailed, failure: error),
        );
      case Ok(:final value):
        final readiness = await findReadinessByToken(value);
        if (isClosed) return;
        emit(
          state.copyWith(
            status: DependentsStatus.ready,
            dependents: value,
            readinessByToken: readiness,
            clearReadiness: readiness == null,
            clearFailure: true,
          ),
        );
    }
  }

  Future<void> refreshReadiness() async {
    final readiness = await findReadinessByToken(state.dependents);
    if (isClosed) return;
    emit(
      state.copyWith(
        readinessByToken: readiness,
        clearReadiness: readiness == null,
      ),
    );
  }

  Future<Map<String, Set<ContractReadinessField>>?> findReadinessByToken(
    List<Dependent> dependents,
  ) async {
    if (dependents.isEmpty) return const {};
    final tokens = [for (final dependent in dependents) dependent.token];
    final result = await findContractReadiness(tokens);
    return switch (result) {
      Ok(:final value) => {
        for (final token in tokens) token: value.gapsOfDependent(token),
      },
      Err() => null,
    };
  }

  void replaceDependent(Dependent dependent) {
    emit(
      state.copyWith(
        dependents: [
          for (final current in state.dependents)
            current.token == dependent.token ? dependent : current,
        ],
      ),
    );
  }

  void addDependent(Dependent dependent) {
    emit(
      state.copyWith(
        status: DependentsStatus.ready,
        dependents: [...state.dependents, dependent],
      ),
    );
  }

  Future<DependentFailure?> removeDependent(String token) async {
    final result = await deleteDependent(token);
    if (result case Err(:final error)) return error;
    await loadDependents();
    return null;
  }

  Future<void> chooseDefault(String token) async {
    if (!state.canChooseDefault) return;
    if (state.defaultToken == token) return;
    if (state.isChangingDefault) return;

    emit(
      state.copyWith(
        status: DependentsStatus.changingDefault,
        clearFailure: true,
      ),
    );
    final result = await setDefaultDependent(token);
    if (result.isErr) {
      emit(
        state.copyWith(
          status: DependentsStatus.ready,
          failure: result.errorOrNull,
        ),
      );
      return;
    }
    await loadDependents();
  }
}
