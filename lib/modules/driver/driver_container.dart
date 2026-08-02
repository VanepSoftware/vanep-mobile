import 'package:get_it/get_it.dart';

import 'presentation/cubit/driver_home_cubit.dart';

void registerDriverHomeDependencies(GetIt getIt) {
  getIt.registerFactory<DriverHomeCubit>(DriverHomeCubit.new);
}
