import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';

class MockIbgeLocationsRepository extends Mock
    implements IbgeLocationsRepository {}

class MockLookupCep extends Mock implements LookupCep {}

class MockListStates extends Mock implements ListStates {}

class MockListCities extends Mock implements ListCities {}
