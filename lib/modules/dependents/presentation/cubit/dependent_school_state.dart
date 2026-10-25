import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

class DependentSchoolState extends Equatable {
  const DependentSchoolState({
    required this.snapshot,
    this.suggestions = const [],
    this.searchFailure,
    this.selectedPlace,
    this.status = DependentEditorStatus.editing,
    this.resolveFailure,
    this.updateFailure,
    this.saved,
  });

  final Dependent snapshot;

  final List<PlaceSuggestion> suggestions;

  final PlaceAutocompleteFailure? searchFailure;

  final PlaceSuggestion? selectedPlace;

  final DependentEditorStatus status;

  final SchoolFailure? resolveFailure;

  final DependentFailure? updateFailure;

  final Dependent? saved;

  bool get isSaving => status == DependentEditorStatus.saving;

  bool get isCurrentSchoolSelected =>
      selectedPlace == null && snapshot.school != null;

  String? get selectedName =>
      selectedPlace?.primaryText ?? snapshot.school?.name;

  bool get canSave => !isSaving && selectedPlace != null;

  DependentSchoolState copyWith({
    List<PlaceSuggestion>? suggestions,
    PlaceAutocompleteFailure? searchFailure,
    bool clearSearchFailure = false,
    PlaceSuggestion? selectedPlace,
    DependentEditorStatus? status,
    SchoolFailure? resolveFailure,
    DependentFailure? updateFailure,
    bool clearSaveFailures = false,
    Dependent? saved,
  }) {
    return DependentSchoolState(
      snapshot: snapshot,
      suggestions: suggestions ?? this.suggestions,
      searchFailure: clearSearchFailure
          ? null
          : searchFailure ?? this.searchFailure,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      status: status ?? this.status,
      resolveFailure: clearSaveFailures
          ? null
          : resolveFailure ?? this.resolveFailure,
      updateFailure: clearSaveFailures
          ? null
          : updateFailure ?? this.updateFailure,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
    snapshot,
    suggestions,
    searchFailure,
    selectedPlace,
    status,
    resolveFailure,
    updateFailure,
    saved,
  ];
}
