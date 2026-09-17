import 'package:equatable/equatable.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/domain/iso_calendar_date.dart';
import '../entities/dependent.dart';

enum DependentField { name, birthDate, gender }

enum DependentDraftError { nameRequired, birthDateInFuture, birthDateInvalid }

class DependentDraft extends Equatable {
  const DependentDraft({this.name = '', this.birthDate, this.gender});

  factory DependentDraft.fromDependent(Dependent dependent) {
    return DependentDraft(
      name: dependent.name,
      birthDate: dependent.birthDate,
      gender: dependent.gender,
    );
  }

  final String name;

  final String? birthDate;

  final Gender? gender;

  DependentDraft withName(String value) {
    return DependentDraft(name: value, birthDate: birthDate, gender: gender);
  }

  DependentDraft withBirthDate(String? value) {
    return DependentDraft(name: name, birthDate: value, gender: gender);
  }

  DependentDraft withGender(Gender? value) {
    return DependentDraft(name: name, birthDate: birthDate, gender: value);
  }

  @override
  List<Object?> get props => [name, birthDate, gender];
}

Map<DependentField, DependentDraftError> validateDependentDraft(
  DependentDraft draft, {
  DateTime? today,
}) {
  final errors = <DependentField, DependentDraftError>{};
  if (draft.name.trim().isEmpty) {
    errors[DependentField.name] = DependentDraftError.nameRequired;
  }
  final birthDateError = findBirthDateError(draft.birthDate, today: today);
  if (birthDateError != null) {
    errors[DependentField.birthDate] = birthDateError;
  }
  return errors;
}

DependentDraftError? findBirthDateError(String? birthDate, {DateTime? today}) {
  if (birthDate == null || birthDate.trim().isEmpty) return null;
  final parsed = parseIsoCalendarDate(birthDate);
  if (parsed == null) return DependentDraftError.birthDateInvalid;
  final reference = today ?? DateTime.now();
  final endOfToday = DateTime(reference.year, reference.month, reference.day);
  if (parsed.isAfter(endOfToday)) return DependentDraftError.birthDateInFuture;
  return null;
}
