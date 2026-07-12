import 'package:get_it/get_it.dart';

import '../environment/environment.dart';

final GetIt getIt = GetIt.instance;

void configureCoreDependencies(Environment environment) {
  if (!getIt.isRegistered<Environment>()) {
    getIt.registerSingleton<Environment>(environment);
  }
}
