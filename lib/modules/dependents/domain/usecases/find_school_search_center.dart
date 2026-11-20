import 'package:vanep_mobile/core/location/device_location_source.dart';
import 'package:vanep_mobile/core/places/place_search_center.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';

class FindSchoolSearchCenter {
  const FindSchoolSearchCenter({
    required this.findMyPersonalAddress,
    required this.deviceLocation,
  });

  final FindMyPersonalAddress findMyPersonalAddress;
  final DeviceLocationSource deviceLocation;

  Future<PlaceSearchCenter?> call(Dependent dependent) async {
    final dependentCenter = placeSearchCenterOrNull(
      dependent.address?.cityLatitude,
      dependent.address?.cityLongitude,
    );
    if (dependentCenter != null) return dependentCenter;

    final clientCenter = await findClientAddressCenter();
    if (clientCenter != null) return clientCenter;

    return deviceLocation.findApproximateLocation();
  }

  Future<PlaceSearchCenter?> findClientAddressCenter() async {
    final personalAddress = (await findMyPersonalAddress()).valueOrNull;
    return placeSearchCenterOrNull(
      personalAddress?.cityLatitude,
      personalAddress?.cityLongitude,
    );
  }
}
