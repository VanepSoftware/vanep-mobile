import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/postal_address_draft.dart';

class PersonalAddress extends Equatable {
  const PersonalAddress({
    required this.token,
    required this.street,
    this.number,
    this.complement,
    this.zipCode,
    this.neighborhood,
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
    cityName,
    cityToken,
    stateUf,
    countryIsoCode,
  ];
}
