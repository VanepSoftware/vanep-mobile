import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_state.dart';

const dependentCepLookupDebounce = Duration(milliseconds: 400);

class DependentPickupCubit extends Cubit<DependentPickupState> {
  DependentPickupCubit({
    required Dependent dependent,
    required this.updateDependent,
    required this.lookupCep,
    required this.listStates,
    required this.listCities,
    this.cepLookupDebounce = dependentCepLookupDebounce,
  }) : super(DependentPickupState.editing(dependent));

  final UpdateDependent updateDependent;
  final LookupCep lookupCep;
  final ListStates listStates;
  final ListCities listCities;
  final Duration cepLookupDebounce;

  Timer? _cepLookupTimer;
  int _cepLookupGeneration = 0;
  int _cityListGeneration = 0;

  void updateZipCode(String value) {
    _cepLookupTimer?.cancel();
    _cepLookupGeneration++;
    final address = state.draft.address.withZipCode(value);
    final willLookUp = address.zipCode.length == brazilianZipDigitCount;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(address),
        clearFailure: true,
        clearCepFailure: true,
        isLookingUpCep: willLookUp,
      ),
    );
    if (!willLookUp) return;
    final generation = _cepLookupGeneration;
    _cepLookupTimer = Timer(cepLookupDebounce, () {
      if (isClosed || generation != _cepLookupGeneration) return;
      lookupDraftCep();
    });
  }

  void updateStreet(String value) {
    emitAddress(state.draft.address.withStreet(value));
  }

  void updateNeighborhood(String value) {
    if (state.draft.address.isNeighborhoodLocked) return;
    emitAddress(state.draft.address.withNeighborhood(value));
  }

  void updateNumber(String value) {
    emitAddress(state.draft.address.withNumber(value));
  }

  void updateComplement(String value) {
    emitAddress(state.draft.address.withComplement(value));
  }

  void emitAddress(PostalAddressDraft address) {
    emit(
      state.copyWith(
        draft: state.draft.withAddress(address),
        clearFailure: true,
      ),
    );
  }

  Future<void> lookupDraftCep() async {
    final cep = state.draft.address.zipCode;
    if (cep.length != brazilianZipDigitCount) return;
    final generation = _cepLookupGeneration;
    final result = await lookupCep(cep);
    if (isClosed || generation != _cepLookupGeneration) return;
    switch (result) {
      case Ok<CepFailure, CepLookup>(value: final lookup):
        emit(
          state.copyWith(
            draft: state.draft.withAddress(
              state.draft.address.withCepLookup(
                cityToken: lookup.cityToken,
                cityName: lookup.cityName,
                uf: lookup.uf,
                street: lookup.street,
                neighborhood: lookup.neighborhood,
              ),
            ),
            clearCepFailure: true,
            isLookingUpCep: false,
          ),
        );
      case Err<CepFailure, CepLookup>(error: final failure):
        await applyCepLookupFailure(failure);
    }
  }

  Future<void> applyCepLookupFailure(CepFailure failure) async {
    if (failure == CepFailure.invalidFormat) {
      emit(state.copyWith(cepFailure: failure, isLookingUpCep: false));
      return;
    }
    final address = failure.blocksSave
        ? state.draft.address.withCepUnknown()
        : state.draft.address.withCepUnavailable();
    emit(
      state.copyWith(
        draft: state.draft.withAddress(address),
        cepFailure: failure,
        isLookingUpCep: false,
      ),
    );
    await refreshStates();
  }

  Future<void> refreshStates() async {
    final result = await listStates();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(catalogStates: value.items, clearCatalogFailure: true),
        );
      case Err(:final error):
        emit(state.copyWith(catalogFailure: error));
    }
  }

  Future<void> selectUf(String uf) async {
    if (state.draft.address.isCityLocked) return;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(state.draft.address.withUf(uf)),
        catalogCities: const [],
        clearFailure: true,
        clearCepFailure: !(state.cepFailure?.blocksSave ?? false),
        clearCatalogFailure: true,
      ),
    );
    await refreshCities(uf);
  }

  Future<void> refreshCities(String uf, {String? search}) async {
    if (uf.isEmpty) return;
    final generation = ++_cityListGeneration;
    final result = search == null || search.isEmpty
        ? await listCities(uf: uf)
        : await listCities(uf: uf, search: search);
    if (isClosed || generation != _cityListGeneration) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(catalogCities: value.items, clearCatalogFailure: true),
        );
      case Err(:final error):
        emit(state.copyWith(catalogFailure: error));
    }
  }

  void selectCity(BrazilianCity city) {
    if (state.draft.address.isCityLocked) return;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(
          state.draft.address.withCity(
            token: city.token,
            name: city.name,
            uf: city.stateUf,
          ),
        ),
        clearFailure: true,
        clearCepFailure: !(state.cepFailure?.blocksSave ?? false),
      ),
    );
  }

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

  @override
  Future<void> close() {
    _cepLookupTimer?.cancel();
    return super.close();
  }
}
