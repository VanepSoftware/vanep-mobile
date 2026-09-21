import 'package:equatable/equatable.dart';

import '../../../ibge_locations/domain/entities/brazilian_city.dart';
import '../../../ibge_locations/domain/entities/brazilian_state.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/failures/ibge_locations_failure.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/value_objects/dependent_draft.dart';

enum DependentFormStatus { editing, saving, saved }

sealed class DependentFieldError extends Equatable {
  const DependentFieldError();

  @override
  List<Object?> get props => const [];
}

final class LocalDependentFieldError extends DependentFieldError {
  const LocalDependentFieldError(this.code);

  final DependentDraftError code;

  @override
  List<Object?> get props => [code];
}

final class BackendDependentFieldError extends DependentFieldError {
  const BackendDependentFieldError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DependentFormState extends Equatable {
  const DependentFormState({
    this.snapshot,
    this.draft = const DependentDraft(),
    this.status = DependentFormStatus.editing,
    this.fieldErrors = const {},
    this.failure,
    this.cepFailure,
    this.isLookingUpCep = false,
    this.catalogStates = const [],
    this.catalogCities = const [],
    this.catalogFailure,
    this.showAddressIssues = false,
  });

  factory DependentFormState.editing(Dependent dependent) {
    return DependentFormState(
      snapshot: dependent,
      draft: DependentDraft.fromDependent(dependent),
    );
  }

  final Dependent? snapshot;

  final DependentDraft draft;

  final DependentFormStatus status;

  final Map<DependentField, DependentFieldError> fieldErrors;

  final DependentFailure? failure;

  final CepFailure? cepFailure;

  final bool isLookingUpCep;

  final List<BrazilianState> catalogStates;

  final List<BrazilianCity> catalogCities;

  final IbgeLocationsFailure? catalogFailure;

  final bool showAddressIssues;

  bool get isCreating => snapshot == null;

  bool get isSaving => status == DependentFormStatus.saving;

  bool get isAddressBlockingSave =>
      isLookingUpCep || draft.address.isZipCodeUnknown;

  bool get showsAddressErrors => showAddressIssues && !draft.address.isBlank;

  DependentFieldError? errorOf(DependentField field) => fieldErrors[field];

  DependentFormState copyWith({
    DependentDraft? draft,
    DependentFormStatus? status,
    Map<DependentField, DependentFieldError>? fieldErrors,
    DependentFailure? failure,
    bool clearFailure = false,
    CepFailure? cepFailure,
    bool clearCepFailure = false,
    bool? isLookingUpCep,
    List<BrazilianState>? catalogStates,
    List<BrazilianCity>? catalogCities,
    IbgeLocationsFailure? catalogFailure,
    bool clearCatalogFailure = false,
    bool? showAddressIssues,
  }) {
    return DependentFormState(
      snapshot: snapshot,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: clearFailure ? null : failure ?? this.failure,
      cepFailure: clearCepFailure ? null : cepFailure ?? this.cepFailure,
      isLookingUpCep: isLookingUpCep ?? this.isLookingUpCep,
      catalogStates: catalogStates ?? this.catalogStates,
      catalogCities: catalogCities ?? this.catalogCities,
      catalogFailure: clearCatalogFailure
          ? null
          : catalogFailure ?? this.catalogFailure,
      showAddressIssues: showAddressIssues ?? this.showAddressIssues,
    );
  }

  @override
  List<Object?> get props => [
    snapshot,
    draft,
    status,
    fieldErrors,
    failure,
    cepFailure,
    isLookingUpCep,
    catalogStates,
    catalogCities,
    catalogFailure,
    showAddressIssues,
  ];
}

Map<DependentField, DependentFieldError> fieldErrorsWithout(
  Map<DependentField, DependentFieldError> errors,
  DependentField field,
) {
  if (!errors.containsKey(field)) return errors;
  final remaining = Map<DependentField, DependentFieldError>.from(errors)
    ..remove(field);
  return remaining;
}
