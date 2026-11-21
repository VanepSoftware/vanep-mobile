import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/phone/phone_caller.dart';

void registerPhoneDependencies(GetIt getIt) {
  getIt.registerLazySingleton<PhoneCaller>(
    () => const UrlLauncherPhoneCaller(),
  );
}
