import '../domain/postal_address_draft.dart';
import 'postal_code_input_formatter.dart';

class PostalAddressDisplayFields {
  const PostalAddressDisplayFields({
    required this.street,
    required this.cityState,
    this.neighborhood,
    this.zipCode,
  });

  final String street;
  final String cityState;
  final String? neighborhood;
  final String? zipCode;

  String get details => [
    ?neighborhood,
    if (cityState.isNotEmpty) cityState,
    ?zipCode,
  ].join(' · ');
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

PostalAddressDisplayFields postalAddressDisplayFields({
  required String street,
  required String cityName,
  required String uf,
  String? number,
  String? complement,
  String? neighborhood,
  String? zipCode,
}) {
  final trimmedNeighborhood = neighborhood?.trim();
  final zipDigits = extractZipDigits(zipCode ?? '');
  return PostalAddressDisplayFields(
    street: joinPostalStreetLine(
      street: street.trim(),
      number: number,
      complement: complement,
    ),
    neighborhood: trimmedNeighborhood == null || trimmedNeighborhood.isEmpty
        ? null
        : trimmedNeighborhood,
    cityState: [cityName, uf].where((part) => part.trim().isNotEmpty).join('/'),
    zipCode: zipDigits.isEmpty ? null : formatBrazilianZip(zipDigits),
  );
}

PostalAddressDisplayFields postalDraftDisplayFields(PostalAddressDraft draft) {
  return postalAddressDisplayFields(
    street: draft.street,
    number: draft.number,
    complement: draft.complement,
    neighborhood: draft.neighborhood,
    cityName: draft.cityName,
    uf: draft.uf,
    zipCode: draft.zipCode,
  );
}
