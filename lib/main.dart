import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:vanep_mobile/app.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/media/media_container.dart';
import 'package:vanep_mobile/core/places/places_container.dart';
import 'package:vanep_mobile/modules/auth/auth_container.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/auth_local_datasource.dart';
import 'package:vanep_mobile/modules/assistant/assistant_container.dart';
import 'package:vanep_mobile/modules/dependents/dependents_container.dart';
import 'package:vanep_mobile/modules/driver/driver_container.dart';
import 'package:vanep_mobile/modules/driver_service_areas/driver_service_areas_container.dart';
import 'package:vanep_mobile/modules/driver_vans/driver_vans_container.dart';
import 'package:vanep_mobile/modules/drivers/drivers_container.dart';
import 'package:vanep_mobile/modules/driver_search/driver_search_container.dart';
import 'package:vanep_mobile/modules/ibge_locations/ibge_locations_container.dart';
import 'package:vanep_mobile/modules/profile/profile_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  configureCoreDependencies(Environment.fromDotEnv(dotenv));

  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk(AuthLocalDataSource.legacyHiveBoxName);
  registerAuthDependencies(getIt, secureStorage: const FlutterSecureStorage());
  registerMediaDependencies(getIt);
  registerDriverDependencies(getIt);
  registerDriverHomeDependencies(getIt);
  registerProfileDependencies(getIt);
  registerPlacesDependencies(getIt);
  registerDriverServiceAreasDependencies(getIt);
  registerDriverSearchDependencies(getIt);
  registerIbgeLocationsDependencies(getIt);
  registerDependentsDependencies(getIt);
  registerAssistantDependencies(getIt);
  registerDriverVansDependencies(getIt);

  runApp(const VanepApp());
}
