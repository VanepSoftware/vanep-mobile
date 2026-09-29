import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';

PersonalAddress fakePersonalAddress({
  String token = 'addr-taguatinga',
  String street = 'QND 12',
  String? number = '10',
  String? complement = 'Casa 2',
  String? zipCode = '72120120',
  String? neighborhood = 'Taguatinga',
  String? districtName,
  String? districtToken,
  String cityName = 'Brasília',
  String cityToken = 'city-brasilia',
  String stateUf = 'DF',
  String countryIsoCode = 'BR',
}) {
  return PersonalAddress(
    token: token,
    street: street,
    number: number,
    complement: complement,
    zipCode: zipCode,
    neighborhood: neighborhood,
    districtName: districtName,
    districtToken: districtToken,
    cityName: cityName,
    cityToken: cityToken,
    stateUf: stateUf,
    countryIsoCode: countryIsoCode,
  );
}

Map<String, Object?> fakePersonalAddressJson({
  String token = 'addr-taguatinga',
  String street = 'QND 12',
  String? number = '10',
  String? complement = 'Casa 2',
  String? zipCode = '72120120',
  String? neighborhood = 'Taguatinga',
  String? districtName,
  String? districtToken,
  String cityName = 'Brasília',
  String cityToken = 'city-brasilia',
  String stateUf = 'DF',
  String countryIsoCode = 'BR',
}) {
  return {
    'token': token,
    'street': street,
    'number': number,
    'complement': complement,
    'zipCode': zipCode,
    'neighborhood': neighborhood,
    'districtName': districtName,
    'districtToken': districtToken,
    'cityName': cityName,
    'cityToken': cityToken,
    'stateUf': stateUf,
    'countryIsoCode': countryIsoCode,
  };
}

Map<String, Object?> fakePersonalAddressJsonWithoutOptionals() {
  return {
    'token': 'addr-taguatinga',
    'street': 'QND 12',
    'cityName': 'Brasília',
    'cityToken': 'city-brasilia',
    'stateUf': 'DF',
    'countryIsoCode': 'BR',
  };
}

PersonalAddressWrite fakePersonalAddressWrite({
  String cityToken = 'city-brasilia',
  String street = 'QND 12',
  String zipCode = '72120120',
  String? number,
  String? complement,
  String? neighborhood,
}) {
  return PersonalAddressWrite(
    cityToken: cityToken,
    street: street,
    zipCode: zipCode,
    number: number,
    complement: complement,
    neighborhood: neighborhood,
  );
}

Map<String, Object?> fakeAddressValidationProblem() {
  return {
    'type': 'about:blank',
    'title': 'Bad Request',
    'status': 400,
    'detail': 'Invalid request content.',
  };
}
