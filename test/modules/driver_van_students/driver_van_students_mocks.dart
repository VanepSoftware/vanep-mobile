import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/share/text_sharer.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/datasources/driver_student_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/create_unlinked_passenger.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/dismiss_student_family_match.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/find_parents_group_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/invite_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/list_driver_students.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/merge_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

class MockDio extends Mock implements Dio {}

class MockDriverStudentRemoteDataSource extends Mock
    implements DriverStudentRemoteDataSource {}

class MockDriverStudentRepository extends Mock
    implements DriverStudentRepository {}

class MockListDriverStudents extends Mock implements ListDriverStudents {}

class MockInviteStudentFamily extends Mock implements InviteStudentFamily {}

class MockFindParentsGroupInvite extends Mock
    implements FindParentsGroupInvite {}

class MockMergeStudentFamily extends Mock implements MergeStudentFamily {}

class MockDismissStudentFamilyMatch extends Mock
    implements DismissStudentFamilyMatch {}

class MockCreateUnlinkedPassenger extends Mock
    implements CreateUnlinkedPassenger {}

class MockResolveSchool extends Mock implements ResolveSchool {}

class MockLookupCep extends Mock implements LookupCep {}

class MockListStates extends Mock implements ListStates {}

class MockListCities extends Mock implements ListCities {}

class MockPlaceAutocompleteController extends Mock
    implements PlaceAutocompleteController {}

class MockTextSharer extends Mock implements TextSharer {}

class FakeUnlinkedPassengerDraft extends Fake
    implements UnlinkedPassengerDraft {}

class MockFindDriverOccupancy extends Mock implements FindDriverOccupancy {}
