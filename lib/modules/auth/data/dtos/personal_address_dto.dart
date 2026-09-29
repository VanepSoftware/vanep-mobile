import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/postal_address_body.dart';
import '../../domain/entities/personal_address.dart';
import '../../domain/value_objects/personal_address_write.dart';

part 'personal_address_dto.freezed.dart';
part 'personal_address_dto.g.dart';

@freezed
abstract class PersonalAddressDto with _$PersonalAddressDto {
  const factory PersonalAddressDto({
    required String token,
    required String street,
    String? number,
    String? complement,
    String? zipCode,
    String? neighborhood,
    String? districtName,
    String? districtToken,
    required String cityName,
    required String cityToken,
    required String stateUf,
    required String countryIsoCode,
  }) = _PersonalAddressDto;

  factory PersonalAddressDto.fromJson(Map<String, Object?> json) =>
      _$PersonalAddressDtoFromJson(json);
}

PersonalAddress personalAddressFromDto(PersonalAddressDto dto) {
  return PersonalAddress(
    token: dto.token,
    street: dto.street,
    number: dto.number,
    complement: dto.complement,
    zipCode: dto.zipCode,
    neighborhood: dto.neighborhood,
    districtName: dto.districtName,
    districtToken: dto.districtToken,
    cityName: dto.cityName,
    cityToken: dto.cityToken,
    stateUf: dto.stateUf,
    countryIsoCode: dto.countryIsoCode,
  );
}

Map<String, Object?> personalAddressUpsertBody(PersonalAddressWrite write) {
  return postalAddressToJson(
    cityToken: write.cityToken,
    street: write.street,
    zipCode: write.zipCode,
    number: write.number,
    complement: write.complement,
    neighborhood: write.neighborhood,
  );
}
