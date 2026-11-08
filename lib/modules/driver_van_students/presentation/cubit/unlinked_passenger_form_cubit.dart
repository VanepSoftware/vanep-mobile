import 'package:vanep_mobile/core/address/postal_address_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/create_unlinked_passenger.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

const unlinkedPassengerCepLookupDebounce = Duration(milliseconds: 400);

class UnlinkedPassengerFormCubit extends Cubit<UnlinkedPassengerFormState>
    with PostalAddressEditor<UnlinkedPassengerFormState> {
  UnlinkedPassengerFormCubit({
    required String? vehicleToken,
    required this.autocomplete,
    required this.resolveSchool,
    required this.lookupCep,
    required this.listStates,
    required this.listCities,
    required this.createUnlinkedPassenger,
    this.cepLookupDebounce = unlinkedPassengerCepLookupDebounce,
  }) : super(
         UnlinkedPassengerFormState(
           draft: UnlinkedPassengerDraft(vehicleToken: vehicleToken),
         ),
       );

  final PlaceAutocompleteController autocomplete;
  final ResolveSchool resolveSchool;
  final LookupCep lookupCep;
  final ListStates listStates;
  final ListCities listCities;
  final CreateUnlinkedPassenger createUnlinkedPassenger;
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
            : state.draft.copyWith(address: edit.address),
        clearSaveFailure: edit.address != null,
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

  void changeName(String value) => emitDraft(state.draft.copyWith(name: value));

  void changeNotes(String value) =>
      emitDraft(state.draft.copyWith(notes: value));

  void selectSchoolShift(SchoolShift shift) =>
      emitDraft(state.draft.copyWith(schoolShift: shift));

  void toggleLeg(RouteLeg leg, Weekday weekday) =>
      emitDraft(state.draft.toggleLeg(weekday, leg));

  void changeTime(Weekday weekday, RouteLeg leg, ClockTime time) =>
      emitDraft(state.draft.changeTime(weekday, leg, time));

  void applyTimeToEveryDay(RouteLeg leg, ClockTime time) =>
      emitDraft(state.draft.applyTimeToEveryDay(leg, time));

  void emitDraft(UnlinkedPassengerDraft draft) {
    emit(state.copyWith(draft: draft, clearSaveFailure: true));
  }

  Future<void> selectSchool(
    PlaceSuggestion suggestion,
    String sessionToken,
  ) async {
    emit(state.copyWith(isResolvingSchool: true, clearSchoolFailure: true));
    final result = await resolveSchool(
      placeId: suggestion.placeId,
      sessionToken: sessionToken,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        autocomplete.session.completeAfterHandover();
        emit(
          state.copyWith(
            draft: state.draft.copyWith(school: value),
            isResolvingSchool: false,
          ),
        );
      case Err(:final error):
        emit(state.copyWith(isResolvingSchool: false, schoolFailure: error));
    }
  }

  void changeZipCode(String value) => updateZipCode(value);
  void changeStreet(String value) => updateStreet(value);
  void changeNumber(String value) => updateNumber(value);
  void changeComplement(String value) => updateComplement(value);
  void changeNeighborhood(String value) => updateNeighborhood(value);

  Future<void> submit() async {
    if (state.blocksSave) return;
    if (!state.draft.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(
      state.copyWith(
        status: UnlinkedPassengerFormStatus.saving,
        clearSaveFailure: true,
      ),
    );
    final result = await createUnlinkedPassenger(state.draft);
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(status: UnlinkedPassengerFormStatus.saved),
      Err(:final error) => state.copyWith(
        status: UnlinkedPassengerFormStatus.editing,
        saveFailure: error,
      ),
    });
  }

  @override
  Future<void> close() {
    autocomplete.dispose();
    return super.close();
  }
}
