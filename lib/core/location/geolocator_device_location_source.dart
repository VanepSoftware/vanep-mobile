import 'package:geolocator/geolocator.dart';

import 'package:vanep_mobile/core/location/device_location_source.dart';
import 'package:vanep_mobile/core/places/place_search_center.dart';

const approximateLocationSettings = LocationSettings(
  accuracy: LocationAccuracy.low,
  timeLimit: Duration(seconds: 5),
);

bool allowsLocation(LocationPermission permission) {
  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}

class GeolocatorDeviceLocationSource implements DeviceLocationSource {
  GeolocatorDeviceLocationSource({GeolocatorPlatform? geolocator})
    : geolocator = geolocator ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform geolocator;

  @override
  Future<PlaceSearchCenter?> findApproximateLocation() async {
    // A location is only a ranking hint: any refusal, timeout, or platform
    // error means "search without a center", never a failure to show.
    try {
      if (!await geolocator.isLocationServiceEnabled()) return null;
      if (!await ensureLocationPermission()) return null;
      final position =
          await geolocator.getLastKnownPosition() ??
          await geolocator.getCurrentPosition(
            locationSettings: approximateLocationSettings,
          );
      return PlaceSearchCenter(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on Exception {
      return null;
    }
  }

  Future<bool> ensureLocationPermission() async {
    final current = await geolocator.checkPermission();
    if (current != LocationPermission.denied) return allowsLocation(current);
    return allowsLocation(await geolocator.requestPermission());
  }
}
