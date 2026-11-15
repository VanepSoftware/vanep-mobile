import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/share/text_sharer.dart';

void registerShareDependencies(GetIt getIt) {
  getIt.registerLazySingleton<TextSharer>(() => const SharePlusTextSharer());
}
