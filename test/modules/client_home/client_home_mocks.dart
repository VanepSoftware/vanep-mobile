import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/find_negotiation_highlights.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';

class MockClientHomeRepository extends Mock implements ClientHomeRepository {}

class MockDailyOverviewDataSource extends Mock
    implements DailyOverviewDataSource {}

class MockResolveSectionWithoutVan extends Mock
    implements ResolveSectionWithoutVan {}

class MockLoadClientHome extends Mock implements LoadClientHome {}

class MockFindNegotiationHighlights extends Mock
    implements FindNegotiationHighlights {}

class MockListClientServiceRequests extends Mock
    implements ListClientServiceRequests {}

class MockClientHomeCubit extends MockCubit<ClientHomeState>
    implements ClientHomeCubit {}
