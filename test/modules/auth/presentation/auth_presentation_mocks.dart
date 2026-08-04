import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/build_authorization_request.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/exchange_authorization_code.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/get_current_session.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_out.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

class MockBuildAuthorizationRequest extends Mock
    implements BuildAuthorizationRequest {}

class MockExchangeAuthorizationCode extends Mock
    implements ExchangeAuthorizationCode {}

class MockSignOut extends Mock implements SignOut {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
