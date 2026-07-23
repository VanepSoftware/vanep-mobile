import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/environment/environment.dart';
import 'modules/auth/auth_container.dart';
import 'modules/auth/data/datasources/auth_local_datasource.dart';
import 'modules/drivers/drivers_container.dart';
import 'modules/profile/profile_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  configureCoreDependencies(Environment.fromDotEnv(dotenv));

  await Hive.initFlutter();
  final authBox = await Hive.openBox<String>(AuthLocalDataSource.boxName);
  registerAuthDependencies(getIt, authBox: authBox);
  registerDriverDependencies(getIt);
  registerProfileDependencies(getIt);

  runApp(const VanepApp());
}
