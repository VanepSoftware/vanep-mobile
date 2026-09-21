import 'package:equatable/equatable.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/domain/iso_calendar_date.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../entities/dependent.dart';

enum DependentField { name, birthDate, gender, address }

enum DependentDraftError { nameRequired, birthDateInFuture, birthDateInvalid }

class DependentDraft extends Equatable {
  const DependentDraft({
    this.name = '',
    this.birthDate,
    this.gender,
    this.address = const PostalAddressDraft(),
  });

  factory DependentDraft.fromDependent(Dependent dependent) {
    return DependentDraft(
      name: dependent.name,
      birthDate: dependent.birthDate,
      gender: dependent.gender,
      address: dependentAddressDraft(dependent.address),
    );
  }

  final String name;

  final String? birthDate;

  final Gender? gender;

  final PostalAddressDraft address;

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

  DependentDraft withAddress(PostalAddressDraft value) {
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

PostalAddressDraft dependentAddressDraft(DependentAddress? address) {
  if (address == null) return const PostalAddressDraft();
  return PostalAddressDraft.fromParts(
    zipCode: address.zipCode,
    cityToken: address.cityToken,
    cityName: address.cityName,
    uf: address.stateUf,
    street: address.street,
    neighborhood: address.neighborhood,
    number: address.number,
    complement: address.complement,
  );
}

bool isDependentAddressEdited(DependentDraft draft, Dependent? snapshot) {
  return !draft.address.sameContentAs(dependentAddressDraft(snapshot?.address));
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

Set<PostalAddressIssue> findAddressIssues(
  DependentDraft draft, {
  Dependent? snapshot,
}) {
  if (draft.address.isBlank || !isDependentAddressEdited(draft, snapshot)) {
    return const {};
  }
  return draft.address.issues;
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
