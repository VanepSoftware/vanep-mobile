import 'package:get_it/get_it.dart';

import '../environment/environment.dart';

/// Global dependency-injection container (constitution R03).
///
/// Feature modules register their own graph through a `*Container` invoked from
/// [configureDependencies]; nothing constructs its own dependencies directly.
final GetIt getIt = GetIt.instance;

/// Registers the cross-cutting dependencies shared by every module.
///
/// Call once at startup, after `.env` is loaded, before `runApp`.
void configureCoreDependencies(Environment environment) {
  if (!getIt.isRegistered<Environment>()) {
    getIt.registerSingleton<Environment>(environment);
  }
}
