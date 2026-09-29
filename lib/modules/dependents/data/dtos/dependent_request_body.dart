import '../../../../core/domain/gender.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/network/postal_address_body.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';

Map<String, Object?>? dependentAddressToJson(PostalAddressDraft address) {
  if (address.isBlank) return null;
  return postalAddressToJson(
    cityToken: address.cityToken,
    street: address.street,
    zipCode: address.zipCode,
    number: address.number,
    complement: address.complement,
    neighborhood: address.neighborhood,
  );
}

Map<String, Object?> dependentChangesToJson(DependentChanges changes) {
  final body = <String, Object?>{};
  if (changes.touches(DependentField.name)) {
    body['name'] = changes.draft.name.trim();
  }
  if (changes.touches(DependentField.birthDate)) {
    body['birthDate'] = normalizeOptional(changes.draft.birthDate);
  }
  if (changes.touches(DependentField.gender)) {
    body['gender'] = Gender.toApi(changes.draft.gender);
  }
  if (changes.touches(DependentField.address)) {
    body['address'] = dependentAddressToJson(changes.draft.address);
  }
  return body;
}
