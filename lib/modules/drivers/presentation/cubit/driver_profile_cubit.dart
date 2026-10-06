import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit({
    required this.findDriverProfile,
    required this.driverToken,
  }) : super(const DriverProfileState());

  final FindDriverProfile findDriverProfile;
  final String driverToken;

  Future<void> loadProfile() async {
    emit(const DriverProfileState());
    final result = await findDriverProfile(driverToken);
    emit(
      result.fold(
        (failure) => DriverProfileState(
          status: DriverProfileStatus.error,
          failure: failure,
        ),
        (profile) => DriverProfileState(
          status: DriverProfileStatus.loaded,
          profile: profile,
        ),
      ),
    );
  }
}
