import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/location/device_location_source.dart';
import 'package:vanep_mobile/core/location/geolocator_device_location_source.dart';

void registerLocationDependencies(GetIt getIt) {
  getIt.registerLazySingleton<DeviceLocationSource>(
    GeolocatorDeviceLocationSource.new,
  );
}
