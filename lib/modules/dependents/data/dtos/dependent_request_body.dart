import '../../../../core/domain/gender.dart';
import '../../domain/value_objects/dependent_address_draft.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';

Map<String, Object?>? dependentAddressToJson(DependentAddressDraft? address) {
  if (address == null) return null;
  return {
    if (address.carriesANewPlace) 'placeId': address.placeId,
    if (address.carriesANewPlace && hasText(address.sessionToken))
      'sessionToken': address.sessionToken,
    'number': normalizeOptional(address.number),
    'complement': normalizeOptional(address.complement),
  };
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
