import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_search_session.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/remove_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/replace_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/set_default_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

import 'dependents_fixtures.dart';

class MockDio extends Mock implements Dio {}

class MockDependentRemoteDataSource extends Mock
    implements DependentRemoteDataSource {}

class MockDependentRepository extends Mock implements DependentRepository {}

class MockDependentSchoolDaysRepository extends Mock
    implements DependentSchoolDaysRepository {}

class MockFindMyDependents extends Mock implements FindMyDependents {}

class MockCreateDependent extends Mock implements CreateDependent {}

class MockUpdateDependent extends Mock implements UpdateDependent {}

class MockSetDefaultDependent extends Mock implements SetDefaultDependent {}

class MockRemoveDependent extends Mock implements RemoveDependent {}

class MockFindSchoolDays extends Mock implements FindSchoolDays {}

class MockReplaceSchoolDays extends Mock implements ReplaceSchoolDays {}

class MockFindContractReadiness extends Mock implements FindContractReadiness {}

class MockResolveSchool extends Mock implements ResolveSchool {}

class MockPlaceAutocompleteController extends Mock
    implements PlaceAutocompleteController {}

class MockPlaceSearchSession extends Mock implements PlaceSearchSession {}

class MockDependentsCubit extends MockCubit<DependentsState>
    implements DependentsCubit {}

DioException dioFailure(int? status, {Object? body}) {
  final requestOptions = RequestOptions(path: '/api/dependent');
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: requestOptions,
            statusCode: status,
            data: body,
          ),
  );
}

const testDependentsEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

void registerDependentFallbackValues() {
  registerFallbackValue(
    const DependentChanges(draft: DependentDraft(), touchedFields: {}),
  );
  registerFallbackValue(const DependentDraft());
  registerFallbackValue(testHelenaDependent);
  registerFallbackValue(const SchoolWeek.empty());
  registerFallbackValue(<String>[]);
}
