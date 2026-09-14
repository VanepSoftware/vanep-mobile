import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/set_default_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

class MockDependentRemoteDataSource extends Mock
    implements DependentRemoteDataSource {}

class MockDependentRepository extends Mock implements DependentRepository {}

class MockFindMyDependents extends Mock implements FindMyDependents {}

class MockCreateDependent extends Mock implements CreateDependent {}

class MockUpdateDependent extends Mock implements UpdateDependent {}

class MockSetDefaultDependent extends Mock implements SetDefaultDependent {}

void registerDependentFallbackValues() {
  registerFallbackValue(
    const DependentChanges(draft: DependentDraft(), touchedFields: {}),
  );
  registerFallbackValue(const DependentDraft());
}
