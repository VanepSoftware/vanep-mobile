import 'package:vanep_mobile/modules/drivers/data/dtos/driver_dto.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';

const testDriverDto = DriverDto(
  token: 'driver-1',
  name: 'Carlos Souza',
  rating: 4.8,
  experienceYears: 8,
  city: 'Taguatinga',
);

const testDriverDtoNoRating = DriverDto(
  token: 'driver-2',
  name: 'Ana Pereira',
  experienceYears: 5,
  city: 'Ceilândia',
);

const testRecentDrivers = [testDriverDto, testDriverDtoNoRating];

Map<String, dynamic> driversPageJson(List<Map<String, dynamic>> content) => {
  'content': content,
  'totalElements': content.length,
  'size': content.length,
  'number': 0,
};

const carlosJson = {
  'token': 'driver-1',
  'name': 'Carlos Souza',
  'photo': 'https://cdn.vanep.com/carlos.jpg',
  'rating': 4.8,
  'experienceYears': 8,
  'city': 'Taguatinga',
};

const carlosProfileJson = {
  'token': 'driver-1',
  'name': 'Carlos Souza',
  'phone': '61999990000',
  'photo': '/api/drivers/driver-1/photo',
  'rating': 4.8,
  'bio': 'Levo criança há 8 anos.',
  'experienceYears': 8,
  'basePrice': 350.0,
  'available': true,
  'serviceAreas': ['Taguatinga', 'Ceilândia', 'Águas Claras'],
  'vehicles': [
    {
      'token': 'van-1',
      'brand': 'Mercedes-Benz',
      'model': 'Sprinter',
      'manufactureYear': 2021,
      'color': 'Branca',
      'capacity': 15,
      'photoFront': '/api/vehicles/van-1/photo-front',
    },
  ],
};

const testDriverProfile = DriverProfileDto(
  token: 'driver-1',
  name: 'Carlos Souza',
  phone: '61999990000',
  rating: 4.8,
  bio: 'Levo criança há 8 anos.',
  experienceYears: 8,
  serviceAreas: ['Taguatinga', 'Ceilândia', 'Águas Claras'],
  vehicles: [
    DriverProfileVehicleDto(
      token: 'van-1',
      brand: 'Mercedes-Benz',
      model: 'Sprinter',
      manufactureYear: 2021,
      color: 'Branca',
      capacity: 15,
    ),
  ],
);

const testDriverProfileWithoutVan = DriverProfileDto(
  token: 'driver-2',
  name: 'Ana Pereira',
);
