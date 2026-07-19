import 'package:bloc_test/bloc_test.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';

class MockDriversCubit extends MockCubit<DriversState> implements DriversCubit {}
