import '../domain/postal_address_draft.dart';

Map<String, Object?> postalAddressToJson({
  required String cityToken,
  required String street,
  required String zipCode,
  String? number,
  String? complement,
  String? neighborhood,
}) {
  return {
    'cityToken': cityToken,
    'street': street.trim(),
    'zipCode': extractZipDigits(zipCode),
    'number': blankToNull(number ?? ''),
    'complement': blankToNull(complement ?? ''),
    'neighborhood': blankToNull(neighborhood ?? ''),
  };
}
