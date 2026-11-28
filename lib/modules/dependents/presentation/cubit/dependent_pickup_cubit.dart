import 'package:vanep_mobile/core/address/postal_address_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_state.dart';

const dependentCepLookupDebounce = Duration(milliseconds: 400);

class DependentPickupCubit extends Cubit<DependentPickupState>
    with PostalAddressEditor<DependentPickupState>
    implements DependentEditorCubit<DependentPickupState> {
  DependentPickupCubit({
    required Dependent dependent,
    required this.updateDependent,
    required this.lookupCep,
    required this.listStates,
    required this.listCities,
    required this.findMyPersonalAddress,
    this.cepLookupDebounce = dependentCepLookupDebounce,
  }) : super(DependentPickupState.editing(dependent));

  final UpdateDependent updateDependent;
  final LookupCep lookupCep;
  final ListStates listStates;
  final ListCities listCities;
  final FindMyPersonalAddress findMyPersonalAddress;
  @override
  final Duration cepLookupDebounce;

  @override
  PostalAddressDraft get editorAddress => state.draft.address;
  @override
  CepFailure? get editorCepFailure => state.cepFailure;
  @override
  LookupCep get addressLookupCep => lookupCep;
  @override
  ListStates get addressListStates => listStates;
  @override
  ListCities get addressListCities => listCities;
  @override
  void emitAddressEdit(PostalAddressEdit edit) {
    emit(
      state.copyWith(
        draft: edit.address == null
            ? null
            : state.draft.withAddress(edit.address!),
        clearFailure: edit.address != null,
        isLookingUpCep: edit.isLookingUpCep,
        cepFailure: edit.cepFailure,
        clearCepFailure: edit.clearCepFailure,
        catalogStates: edit.catalogStates,
        catalogCities: edit.catalogCities,
        catalogFailure: edit.catalogFailure,
        clearCatalogFailure: edit.clearCatalogFailure,
      ),
    );
  }

  Future<void> loadProfileAddress() async {
    final result = await findMyPersonalAddress();
    if (isClosed) return;
    if (result case Ok<PersonalAddressFailure, PersonalAddress?>(
      :final value?,
    )) {
      emit(state.copyWith(profileAddress: value));
    }
  }

  void useProfileAddress() {
    final profile = state.profileAddress;
    if (profile == null || state.isSaving) return;
    cancelAddressLookup();
    emitAddressEdit(
      PostalAddressEdit(
        address: profile.toDraft(),
        isLookingUpCep: false,
        clearCepFailure: true,
        clearCatalogFailure: true,
      ),
    );
  }

  @override
  Future<void> save() async {
    if (!state.canSave) return;

    if (state.addressIssues.isNotEmpty) {
      emit(state.copyWith(showAddressIssues: true));
      return;
    }

    emit(
      state.copyWith(status: DependentEditorStatus.saving, clearFailure: true),
    );

    final snapshot = state.snapshot;
    final result = await updateDependent(
      snapshot: snapshot,
      draft: state.draft,
    );
    if (isClosed) return;
    switch (result) {
      case null:
        emit(
          state.copyWith(status: DependentEditorStatus.saved, saved: snapshot),
        );
      case Ok<DependentFailure, Dependent>(:final value):
        emit(state.copyWith(status: DependentEditorStatus.saved, saved: value));
      case Err<DependentFailure, Dependent>(:final error):
        emit(
          state.copyWith(
            status: DependentEditorStatus.editing,
            draft: draftAfterFailure(error),
            failure: error,
          ),
        );
        if (error is DependentCityNotFoundFailure) await refreshStates();
    }
  }

  DependentDraft draftAfterFailure(DependentFailure failure) {
    if (failure is! DependentCityNotFoundFailure) return state.draft;
    return state.draft.withAddress(
      state.draft.address.withUf(state.draft.address.uf),
    );
  }
}
