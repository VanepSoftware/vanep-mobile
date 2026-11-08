import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_state.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

const schoolPlacePrimaryTypes = [
  'school',
  'primary_school',
  'secondary_school',
];

class DependentSchoolCubit extends Cubit<DependentSchoolState>
    implements DependentEditorCubit<DependentSchoolState> {
  DependentSchoolCubit({
    required Dependent dependent,
    required this.autocomplete,
    required this.resolveSchool,
    required this.updateDependent,
  }) : super(DependentSchoolState(snapshot: dependent));

  final PlaceAutocompleteController autocomplete;
  final ResolveSchool resolveSchool;
  final UpdateDependent updateDependent;

  void search(String input) {
    autocomplete.search(input, (result) {
      if (isClosed) return;
      emit(switch (result) {
        Ok(:final value) => state.copyWith(
          suggestions: value,
          clearSearchFailure: true,
        ),
        Err(:final error) => state.copyWith(
          suggestions: const [],
          searchFailure: error,
        ),
      });
    });
  }

  void selectSuggestion(PlaceSuggestion suggestion) {
    emit(state.copyWith(selectedPlace: suggestion, clearSaveFailures: true));
  }

  @override
  Future<void> save() async {
    final place = state.selectedPlace;
    if (!state.canSave || place == null) return;

    emit(
      state.copyWith(
        status: DependentEditorStatus.saving,
        clearSaveFailures: true,
      ),
    );

    final resolved = await resolveSchool(
      placeId: place.placeId,
      sessionToken: autocomplete.session.currentToken(),
    );
    if (isClosed) return;
    switch (resolved) {
      case Err(:final error):
        emit(
          state.copyWith(
            status: DependentEditorStatus.editing,
            resolveFailure: error,
          ),
        );
        return;
      case Ok(:final value):
        autocomplete.session.completeAfterHandover();
        await saveSchoolToken(value.token);
    }
  }

  Future<void> saveSchoolToken(String schoolToken) async {
    final snapshot = state.snapshot;
    final result = await updateDependent(
      snapshot: snapshot,
      draft: DependentDraft.fromDependent(snapshot)
          .withSchoolToken(schoolToken),
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
            updateFailure: error,
          ),
        );
    }
  }

  @override
  Future<void> close() {
    autocomplete.dispose();
    return super.close();
  }
}
