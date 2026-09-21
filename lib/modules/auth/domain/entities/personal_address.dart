import 'package:equatable/equatable.dart';

import '../../../../core/domain/postal_address_draft.dart';

class PersonalAddress extends Equatable {
  const PersonalAddress({
    required this.token,
    required this.street,
    this.number,
    this.complement,
    this.zipCode,
    this.neighborhood,
    this.districtName,
    this.districtToken,
    required this.cityName,
    required this.cityToken,
    required this.stateUf,
    required this.countryIsoCode,
  });

  final String token;

  final String street;

  final String? number;

  final String? complement;

  final String? zipCode;

  final String? neighborhood;

  final String? districtName;

  final String? districtToken;

  final String cityName;

  final String cityToken;

  final String stateUf;

  final String countryIsoCode;

  PostalAddressDraft toDraft() {
    return PostalAddressDraft.fromParts(
      zipCode: zipCode,
      cityToken: cityToken,
      cityName: cityName,
      uf: stateUf,
      street: street,
      neighborhood: neighborhood,
      number: number,
      complement: complement,
    );
  }

  @override
  List<Object?> get props => [
    token,
    street,
    number,
    complement,
    zipCode,
    neighborhood,
    districtName,
    districtToken,
    cityName,
    cityToken,
    stateUf,
    countryIsoCode,
  ];
}
