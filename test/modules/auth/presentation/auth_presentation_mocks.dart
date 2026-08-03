import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/build_authorization_request.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/exchange_authorization_code.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/get_current_session.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/patch_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/refresh_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/request_email_change.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_out.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

class MockBuildAuthorizationRequest extends Mock
    implements BuildAuthorizationRequest {}

class MockExchangeAuthorizationCode extends Mock
    implements ExchangeAuthorizationCode {}

class MockSignOut extends Mock implements SignOut {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockRefreshUserProfile extends Mock implements RefreshUserProfile {}

class MockPatchUserProfile extends Mock implements PatchUserProfile {}

class MockRequestEmailChange extends Mock implements RequestEmailChange {}

class MockPersonalDataCubit extends MockCubit<PersonalDataState>
    implements PersonalDataCubit {}
