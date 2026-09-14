import 'package:equatable/equatable.dart';

import '../entities/dependent.dart';
import 'dependent_draft.dart';

class DependentChanges extends Equatable {
  const DependentChanges({required this.draft, required this.touchedFields});

  final DependentDraft draft;

  final Set<DependentField> touchedFields;

  bool get isEmpty => touchedFields.isEmpty;

  bool touches(DependentField field) => touchedFields.contains(field);

  @override
  List<Object?> get props => [draft, touchedFields];
}

DependentChanges buildDependentChangesForCreate(DependentDraft draft) {
  final touched = <DependentField>{DependentField.name};
  if (hasText(draft.birthDate)) touched.add(DependentField.birthDate);
  if (draft.gender != null) touched.add(DependentField.gender);
  return DependentChanges(draft: draft, touchedFields: touched);
}

DependentChanges buildDependentChangesForUpdate({
  required DependentDraft draft,
  required Dependent snapshot,
}) {
  final touched = <DependentField>{};
  if (draft.name.trim() != snapshot.name.trim()) {
    touched.add(DependentField.name);
  }
  if (normalizeOptional(draft.birthDate) !=
      normalizeOptional(snapshot.birthDate)) {
    touched.add(DependentField.birthDate);
  }
  if (draft.gender != snapshot.gender) {
    touched.add(DependentField.gender);
  }
  return DependentChanges(draft: draft, touchedFields: touched);
}

bool hasText(String? value) => value != null && value.trim().isNotEmpty;

String? normalizeOptional(String? value) {
  if (!hasText(value)) return null;
  return value!.trim();
}
