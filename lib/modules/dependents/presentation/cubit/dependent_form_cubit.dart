import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/result/result.dart';
import '../../../ibge_locations/domain/entities/brazilian_city.dart';
import '../../../ibge_locations/domain/entities/cep_lookup.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/usecases/list_cities.dart';
import '../../../ibge_locations/domain/usecases/list_states.dart';
import '../../../ibge_locations/domain/usecases/lookup_cep.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/usecases/create_dependent.dart';
import '../../domain/usecases/update_dependent.dart';
import '../../domain/value_objects/dependent_draft.dart';
import 'dependent_form_state.dart';

const dependentCepLookupDebounce = Duration(milliseconds: 400);

class DependentFormCubit extends Cubit<DependentFormState> {
  DependentFormCubit({
    required this.createDependent,
    required this.updateDependent,
    required this.lookupCep,
    required this.listStates,
    required this.listCities,
    this.cepLookupDebounce = dependentCepLookupDebounce,
    Dependent? dependent,
  }) : super(
         dependent == null
             ? const DependentFormState()
             : DependentFormState.editing(dependent),
       );

  final CreateDependent createDependent;
  final UpdateDependent updateDependent;
  final LookupCep lookupCep;
  final ListStates listStates;
  final ListCities listCities;
  final Duration cepLookupDebounce;

  Timer? _cepLookupTimer;
  int _cepLookupGeneration = 0;

  void changeName(String value) {
    emit(
      state.copyWith(
        draft: state.draft.withName(value),
        fieldErrors: fieldErrorsWithout(state.fieldErrors, DependentField.name),
        clearFailure: true,
      ),
    );
  }

  void changeBirthDate(String? value) {
    emit(
      state.copyWith(
        draft: state.draft.withBirthDate(value),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.birthDate,
        ),
        clearFailure: true,
      ),
    );
  }

  void changeGender(Gender? value) {
    emit(
      state.copyWith(
        draft: state.draft.withGender(value),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.gender,
        ),
        clearFailure: true,
      ),
    );
  }

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
    final address = failure == CepFailure.notFound
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
        clearCepFailure: state.cepFailure != CepFailure.notFound,
        clearCatalogFailure: true,
      ),
    );
    await refreshCities(uf);
  }

  Future<void> refreshCities(String uf, {String? search}) async {
    if (uf.isEmpty) return;
    final result = search == null || search.isEmpty
        ? await listCities(uf: uf)
        : await listCities(uf: uf, search: search);
    if (isClosed) return;
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
        clearCepFailure: state.cepFailure != CepFailure.notFound,
      ),
    );
  }

  void clearAddress() {
    _cepLookupTimer?.cancel();
    _cepLookupGeneration++;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(const PostalAddressDraft()),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.address,
        ),
        clearFailure: true,
        clearCepFailure: true,
        isLookingUpCep: false,
        showAddressIssues: false,
      ),
    );
  }

  Future<void> save() async {
    if (state.isSaving || state.isAddressBlockingSave) return;

    final localErrors = validateDependentDraft(state.draft);
    final addressIssues = findAddressIssues(
      state.draft,
      snapshot: state.snapshot,
    );
    if (localErrors.isNotEmpty || addressIssues.isNotEmpty) {
      emit(
        state.copyWith(
          fieldErrors: localFieldErrors(localErrors),
          showAddressIssues: addressIssues.isNotEmpty,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DependentFormStatus.saving,
        fieldErrors: const {},
        clearFailure: true,
      ),
    );

    final result = await runSave();
    switch (result) {
      case null || Ok<DependentFailure, Dependent>():
        emit(state.copyWith(status: DependentFormStatus.saved));
      case Err<DependentFailure, Dependent>(error: final failure):
        emit(
          state.copyWith(
            status: DependentFormStatus.editing,
            draft: draftAfterFailure(failure),
            failure: failure,
            fieldErrors: backendFieldErrors(failure),
          ),
        );
        if (failure is DependentCityNotFoundFailure) await refreshStates();
    }
  }

  DependentDraft draftAfterFailure(DependentFailure failure) {
    if (failure is! DependentCityNotFoundFailure) return state.draft;
    return state.draft.withAddress(
      state.draft.address.withUf(state.draft.address.uf),
    );
  }

  Future<Result<DependentFailure, Dependent>?> runSave() {
    final snapshot = state.snapshot;
    if (snapshot == null) return createDependent(state.draft);
    return updateDependent(snapshot: snapshot, draft: state.draft);
  }

  @override
  Future<void> close() {
    _cepLookupTimer?.cancel();
    return super.close();
  }
}

Map<DependentField, DependentFieldError> localFieldErrors(
  Map<DependentField, DependentDraftError> errors,
) {
  return errors.map(
    (field, code) => MapEntry(field, LocalDependentFieldError(code)),
  );
}

Map<DependentField, DependentFieldError> backendFieldErrors(
  DependentFailure failure,
) {
  if (failure is! DependentValidationFailure) return const {};
  return failure.messagesByField.map(
    (field, message) => MapEntry(field, BackendDependentFieldError(message)),
  );
}
