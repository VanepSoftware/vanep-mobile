import 'package:vanep_mobile/modules/driver_vans/data/dtos/driver_van_dto.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_target.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';

const testVan = DriverVanDto(
  token: 'van-1',
  plate: 'ABC1D23',
  brand: 'Mercedes-Benz',
  model: 'Sprinter',
  manufactureYear: 2021,
  color: 'Branca',
  capacity: 15,
  photoFrontUrl: '/api/vehicles/van-1/photo-front?v=1',
);

const testVanJson = {
  'token': 'van-1',
  'driverToken': 'driver-1',
  'plate': 'ABC1D23',
  'brand': 'Mercedes-Benz',
  'model': 'Sprinter',
  'manufactureYear': 2021,
  'color': 'Branca',
  'capacity': 15,
  'photoFrontUrl': '/api/vehicles/van-1/photo-front?v=1',
  'photoSideUrl': null,
  'photoDocumentUrl': null,
  'active': true,
};

const validRegistration = VanRegistration(
  plate: 'abc1d23',
  brand: ' Mercedes-Benz ',
  model: 'Sprinter',
  manufactureYear: '2021',
  color: 'Branca',
  capacity: '15',
);

const frontOfTestVan = VanPhotoTarget(
  vanToken: 'van-1',
  side: VanPhotoSide.front,
);
