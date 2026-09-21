import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/formatters/postal_code_input_formatter.dart';
import '../../domain/entities/personal_address.dart';

class PersonalAddressDisplayFields {
  const PersonalAddressDisplayFields({
    required this.street,
    required this.cityState,
    this.neighborhood,
    this.zipCode,
  });

  final String street;
  final String cityState;
  final String? neighborhood;
  final String? zipCode;
}

String joinPostalStreetLine({
  required String street,
  String? number,
  String? complement,
}) {
  final parts = <String>[street];
  final trimmedNumber = number?.trim();
  if (trimmedNumber != null && trimmedNumber.isNotEmpty) {
    parts.add(trimmedNumber);
  }
  final trimmedComplement = complement?.trim();
  if (trimmedComplement != null && trimmedComplement.isNotEmpty) {
    parts.add(trimmedComplement);
  }
  return parts.join(', ');
}

PersonalAddressDisplayFields personalAddressDisplayFields(
  PersonalAddress address,
) {
  final neighborhood = address.neighborhood?.trim();
  final zipDigits = extractZipDigits(address.zipCode ?? '');
  return PersonalAddressDisplayFields(
    street: joinPostalStreetLine(
      street: address.street,
      number: address.number,
      complement: address.complement,
    ),
    neighborhood: neighborhood == null || neighborhood.isEmpty
        ? null
        : neighborhood,
    cityState: '${address.cityName}/${address.stateUf}',
    zipCode: zipDigits.isEmpty ? null : formatBrazilianZip(zipDigits),
  );
}
