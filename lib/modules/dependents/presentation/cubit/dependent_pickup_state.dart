import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';

class DependentPickupState extends Equatable implements DependentEditorState {
  const DependentPickupState({
    required this.snapshot,
    required this.draft,
    this.status = DependentEditorStatus.editing,
    this.failure,
    this.cepFailure,
    this.isLookingUpCep = false,
    this.catalogStates = const [],
    this.catalogCities = const [],
    this.catalogFailure,
    this.showAddressIssues = false,
    this.saved,
  });

  factory DependentPickupState.editing(Dependent dependent) {
    return DependentPickupState(
      snapshot: dependent,
      draft: DependentDraft.fromDependent(dependent),
    );
  }

  final Dependent snapshot;

  final DependentDraft draft;

  final DependentEditorStatus status;

  final DependentFailure? failure;

  final CepFailure? cepFailure;

  final bool isLookingUpCep;

  final List<BrazilianState> catalogStates;

  final List<BrazilianCity> catalogCities;

  final IbgeLocationsFailure? catalogFailure;

  final bool showAddressIssues;

  final Dependent? saved;

  @override
  bool get isSaving => status == DependentEditorStatus.saving;

  @override
  bool get isSaved => status == DependentEditorStatus.saved;

  bool get isAddressBlockingSave =>
      isLookingUpCep || draft.address.isZipCodeUnknown;

  bool get showsAddressErrors => showAddressIssues && !draft.address.isBlank;

  Set<PostalAddressIssue> get addressIssues =>
      findAddressIssues(draft, snapshot: snapshot);

  bool get hasChanges => isDependentAddressEdited(draft, snapshot);

  @override
  bool get canSave => !isSaving && !isAddressBlockingSave && hasChanges;

  DependentPickupState copyWith({
    DependentDraft? draft,
    DependentEditorStatus? status,
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
    Dependent? saved,
  }) {
    return DependentPickupState(
      snapshot: snapshot,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
      cepFailure: clearCepFailure ? null : cepFailure ?? this.cepFailure,
      isLookingUpCep: isLookingUpCep ?? this.isLookingUpCep,
      catalogStates: catalogStates ?? this.catalogStates,
      catalogCities: catalogCities ?? this.catalogCities,
      catalogFailure: clearCatalogFailure
          ? null
          : catalogFailure ?? this.catalogFailure,
      showAddressIssues: showAddressIssues ?? this.showAddressIssues,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
    snapshot,
    draft,
    status,
    failure,
    cepFailure,
    isLookingUpCep,
    catalogStates,
    catalogCities,
    catalogFailure,
    showAddressIssues,
    saved,
  ];
}
