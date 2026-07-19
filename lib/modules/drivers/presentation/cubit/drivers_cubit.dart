import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/list_recent_drivers.dart';
import 'drivers_state.dart';

class DriversCubit extends Cubit<DriversState> {
  DriversCubit({required this._listRecentDrivers})
    : super(const DriversState());

  final ListRecentDrivers _listRecentDrivers;

  Future<void> loadRecentDrivers() async {
    emit(state.copyWith(status: DriversStatus.loading));
    final result = await _listRecentDrivers();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: DriversStatus.error, failure: failure)),
      (drivers) =>
          emit(state.copyWith(status: DriversStatus.loaded, drivers: drivers)),
    );
  }

  void search(String query) {
    emit(state.copyWith(query: query));
  }
}
