import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_state.dart';

class DependentDetailCubit extends Cubit<DependentDetailState> {
  DependentDetailCubit({
    required this.dependentToken,
    required this.findSchoolDays,
  }) : super(const DependentDetailState());

  final String dependentToken;
  final FindSchoolDays findSchoolDays;

  Future<void> loadSchoolWeek() async {
    emit(const DependentDetailState());
    final result = await findSchoolDays(dependentToken);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => DependentDetailState(
        status: DependentDetailStatus.loaded,
        week: value,
      ),
      Err() => const DependentDetailState(
        status: DependentDetailStatus.loadFailed,
      ),
    });
  }

  void applySavedWeek(SchoolWeek week) {
    emit(
      DependentDetailState(status: DependentDetailStatus.loaded, week: week),
    );
  }
}
