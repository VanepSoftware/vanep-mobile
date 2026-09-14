import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/find_my_dependents.dart';
import '../../domain/usecases/set_default_dependent.dart';
import 'dependents_state.dart';

class DependentsCubit extends Cubit<DependentsState> {
  DependentsCubit({
    required this.findMyDependents,
    required this.setDefaultDependent,
  }) : super(const DependentsState());

  final FindMyDependents findMyDependents;
  final SetDefaultDependent setDefaultDependent;

  Future<void> loadDependents() async {
    emit(state.copyWith(status: DependentsStatus.loading, clearFailure: true));
    final result = await findMyDependents();
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DependentsStatus.loadFailed,
          failure: failure,
        ),
        (dependents) => state.copyWith(
          status: DependentsStatus.ready,
          dependents: dependents,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> chooseDefault(String token) async {
    if (!state.canChooseDefault) return;
    if (state.defaultToken == token) return;

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
