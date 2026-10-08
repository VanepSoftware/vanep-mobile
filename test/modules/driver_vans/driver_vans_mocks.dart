import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_vans/data/datasources/driver_van_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/repositories/driver_van_repository.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/change_van_photo.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/register_van.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';

class MockDriverVanRemoteDataSource extends Mock
    implements DriverVanRemoteDataSource {}

class MockDriverVanRepository extends Mock implements DriverVanRepository {}

class MockListMyVans extends Mock implements ListMyVans {}

class MockRegisterVan extends Mock implements RegisterVan {}

class MockChangeVanPhoto extends Mock implements ChangeVanPhoto {}

class MockDriverVansCubit extends MockCubit<DriverVansState>
    implements DriverVansCubit {}
