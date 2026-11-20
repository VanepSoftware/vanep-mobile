import 'package:vanep_mobile/core/places/place_search_center.dart';

abstract class DeviceLocationSource {
  Future<PlaceSearchCenter?> findApproximateLocation();
}
