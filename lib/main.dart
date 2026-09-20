import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/environment/environment.dart';
import 'core/places/places_container.dart';
import 'modules/auth/auth_container.dart';
import 'modules/auth/data/datasources/auth_local_datasource.dart';
import 'modules/dependents/dependents_container.dart';
import 'modules/driver/driver_container.dart';
import 'modules/driver_service_areas/driver_service_areas_container.dart';
import 'modules/drivers/drivers_container.dart';
import 'modules/driver_search/driver_search_container.dart';
import 'modules/profile/profile_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  configureCoreDependencies(Environment.fromDotEnv(dotenv));

  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk(AuthLocalDataSource.legacyHiveBoxName);
  registerAuthDependencies(getIt, secureStorage: const FlutterSecureStorage());
  registerDriverDependencies(getIt);
  registerDriverHomeDependencies(getIt);
  registerProfileDependencies(getIt);
  registerPlacesDependencies(getIt);
  registerDriverServiceAreasDependencies(getIt);
  registerDriverSearchDependencies(getIt);
  registerDependentsDependencies(getIt);

  runApp(const VanepApp());
}
