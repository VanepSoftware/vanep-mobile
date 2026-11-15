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
import 'package:vanep_mobile/modules/client_home/client_home_container.dart';
import 'package:vanep_mobile/modules/client_proposals/client_proposals_container.dart';
import 'package:vanep_mobile/modules/contract_readiness/contract_readiness_container.dart';
import 'package:vanep_mobile/modules/conversations/conversations_container.dart';
import 'package:vanep_mobile/modules/dependents/dependents_container.dart';
import 'package:vanep_mobile/modules/driver/driver_container.dart';
import 'package:vanep_mobile/modules/driver_service_areas/driver_service_areas_container.dart';
import 'package:vanep_mobile/modules/driver_van_central/driver_van_central_container.dart';
import 'package:vanep_mobile/modules/driver_vans/driver_vans_container.dart';
import 'package:vanep_mobile/modules/drivers/drivers_container.dart';
import 'package:vanep_mobile/modules/driver_proposals/driver_proposals_container.dart';
import 'package:vanep_mobile/modules/driver_search/driver_search_container.dart';
import 'package:vanep_mobile/modules/ibge_locations/ibge_locations_container.dart';
import 'package:vanep_mobile/modules/negotiations/negotiations_container.dart';
import 'package:vanep_mobile/modules/profile/profile_container.dart';
import 'package:vanep_mobile/modules/schools/schools_container.dart';
import 'package:vanep_mobile/modules/settings/data/datasources/settings_local_datasource.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/get_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/settings_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  configureCoreDependencies(Environment.fromDotEnv(dotenv));

  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk(AuthLocalDataSource.legacyHiveBoxName);
  registerSettingsDependencies(
    getIt,
    settingsBox: await Hive.openBox<String>(SettingsLocalDataSource.boxName),
  );
  registerAuthDependencies(getIt, secureStorage: const FlutterSecureStorage());
  registerMediaDependencies(getIt);
  registerDriverDependencies(getIt);
  registerDriverHomeDependencies(getIt);
  registerProfileDependencies(getIt);
  registerPlacesDependencies(getIt);
  registerDriverServiceAreasDependencies(getIt);
  registerDriverSearchDependencies(getIt);
  registerIbgeLocationsDependencies(getIt);
  registerSchoolsDependencies(getIt);
  registerContractReadinessDependencies(getIt);
  registerNegotiationsDependencies(getIt);
  registerDependentsDependencies(getIt);
  registerAssistantDependencies(getIt);
  registerDriverVansDependencies(getIt);
  registerDriverVanCentralDependencies(getIt);
  registerConversationsDependencies(getIt);
  registerClientHomeDependencies(getIt);
  registerClientProposalsDependencies(getIt);
  registerDriverProposalsDependencies(getIt);

  final themePreference = await getIt<GetThemePreference>()();
  runApp(VanepApp(initialThemePreference: themePreference));
}
