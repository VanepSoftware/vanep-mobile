import 'package:vanep_mobile/modules/drivers/data/dtos/driver_dto.dart';

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
