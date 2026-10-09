import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';

void registerDriverHomeDependencies(GetIt getIt) {
  getIt.registerFactory<DriverHomeCubit>(DriverHomeCubit.new);
}
