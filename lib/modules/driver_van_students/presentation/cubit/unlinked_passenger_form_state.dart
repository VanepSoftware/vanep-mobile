import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

enum UnlinkedPassengerFormStatus { editing, saving, saved }

class UnlinkedPassengerFormState extends Equatable {
  const UnlinkedPassengerFormState({
    required this.draft,
    this.status = UnlinkedPassengerFormStatus.editing,
    this.showErrors = false,
    this.isResolvingSchool = false,
    this.schoolFailure,
    this.isLookingUpCep = false,
    this.cepFailure,
    this.catalogStates = const [],
    this.catalogCities = const [],
    this.catalogFailure,
    this.saveFailure,
  });

  final UnlinkedPassengerDraft draft;
  final UnlinkedPassengerFormStatus status;
  final bool showErrors;
  final bool isResolvingSchool;
  final SchoolFailure? schoolFailure;
  final bool isLookingUpCep;
  final CepFailure? cepFailure;
  final List<BrazilianState> catalogStates;
  final List<BrazilianCity> catalogCities;
  final IbgeLocationsFailure? catalogFailure;
  final DriverStudentFailure? saveFailure;

  bool get isSaving => status == UnlinkedPassengerFormStatus.saving;

  Set<UnlinkedPassengerDraftError> get visibleErrors =>
      showErrors ? draft.errors : const {};

  bool get blocksSave =>
      isSaving ||
      isResolvingSchool ||
      isLookingUpCep ||
      draft.address.isZipCodeUnknown;

  UnlinkedPassengerFormState copyWith({
    UnlinkedPassengerDraft? draft,
    UnlinkedPassengerFormStatus? status,
    bool? showErrors,
    bool? isResolvingSchool,
    SchoolFailure? schoolFailure,
    bool clearSchoolFailure = false,
    bool? isLookingUpCep,
    CepFailure? cepFailure,
    bool clearCepFailure = false,
    List<BrazilianState>? catalogStates,
    List<BrazilianCity>? catalogCities,
    IbgeLocationsFailure? catalogFailure,
    bool clearCatalogFailure = false,
    DriverStudentFailure? saveFailure,
    bool clearSaveFailure = false,
  }) {
    return UnlinkedPassengerFormState(
      draft: draft ?? this.draft,
      status: status ?? this.status,
      showErrors: showErrors ?? this.showErrors,
      isResolvingSchool: isResolvingSchool ?? this.isResolvingSchool,
      schoolFailure: clearSchoolFailure
          ? null
          : schoolFailure ?? this.schoolFailure,
      isLookingUpCep: isLookingUpCep ?? this.isLookingUpCep,
      cepFailure: clearCepFailure ? null : cepFailure ?? this.cepFailure,
      catalogStates: catalogStates ?? this.catalogStates,
      catalogCities: catalogCities ?? this.catalogCities,
      catalogFailure: clearCatalogFailure
          ? null
          : catalogFailure ?? this.catalogFailure,
      saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    status,
    showErrors,
    isResolvingSchool,
    schoolFailure,
    isLookingUpCep,
    cepFailure,
    catalogStates,
    catalogCities,
    catalogFailure,
    saveFailure,
  ];
}
