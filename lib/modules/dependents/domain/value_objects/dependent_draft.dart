import 'package:equatable/equatable.dart';

import '../../../../core/domain/gender.dart';
import '../entities/dependent.dart';
import 'dependent_address_draft.dart';

enum DependentField { name, birthDate, gender, address }

enum DependentDraftError { nameRequired, birthDateInFuture, birthDateInvalid }

class DependentDraft extends Equatable {
  const DependentDraft({
    this.name = '',
    this.birthDate,
    this.gender,
    this.address,
  });

  factory DependentDraft.fromDependent(Dependent dependent) {
    final address = dependent.address;
    return DependentDraft(
      name: dependent.name,
      birthDate: dependent.birthDate,
      gender: dependent.gender,
      address: address == null
          ? null
          : DependentAddressDraft.fromAddress(address),
    );
  }

  final String name;

  final String? birthDate;

  final Gender? gender;

  final DependentAddressDraft? address;

  DependentDraft withName(String value) {
    return DependentDraft(
      name: value,
      birthDate: birthDate,
      gender: gender,
      address: address,
    );
  }

  DependentDraft withBirthDate(String? value) {
    return DependentDraft(
      name: name,
      birthDate: value,
      gender: gender,
      address: address,
    );
  }

  DependentDraft withGender(Gender? value) {
    return DependentDraft(
      name: name,
      birthDate: birthDate,
      gender: value,
      address: address,
    );
  }

  DependentDraft withAddress(DependentAddressDraft? value) {
    return DependentDraft(
      name: name,
      birthDate: birthDate,
      gender: gender,
      address: value,
    );
  }

  @override
  List<Object?> get props => [name, birthDate, gender, address];
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
  final parsed = DateTime.tryParse(birthDate.trim());
  if (parsed == null) return DependentDraftError.birthDateInvalid;
  final reference = today ?? DateTime.now();
  final endOfToday = DateTime(reference.year, reference.month, reference.day);
  if (parsed.isAfter(endOfToday)) return DependentDraftError.birthDateInFuture;
  return null;
}
