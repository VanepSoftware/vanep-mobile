import '../../../../core/domain/gender.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../../domain/value_objects/dependent_draft.dart';

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
  return body;
}
