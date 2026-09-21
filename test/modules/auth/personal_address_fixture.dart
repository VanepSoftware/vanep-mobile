import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';

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
