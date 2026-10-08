import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit() : super(const DriverHomeState());

  void seedToday({required String shiftStartTime}) {
    emit(state.copyWith(shiftStartTime: shiftStartTime));
  }

  void startRoute() {
    emit(state.copyWith(shift: DriverShift.on));
  }

  void endRoute() {
    emit(state.copyWith(shift: DriverShift.off));
  }

  void setLocationSharing(bool sharing) {
    emit(state.copyWith(sharingLocation: sharing));
  }
}
