import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/build_authorization_request.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/complete_google_signup.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/exchange_authorization_code.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/get_current_session.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/patch_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/refresh_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/request_email_change.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/resend_email_verification_code.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_in_with_google.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_in_with_password.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_out.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_up.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/verify_email_code.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

class MockBuildAuthorizationRequest extends Mock
    implements BuildAuthorizationRequest {}

class MockExchangeAuthorizationCode extends Mock
    implements ExchangeAuthorizationCode {}

class MockSignOut extends Mock implements SignOut {}

class MockRefreshUserProfile extends Mock implements RefreshUserProfile {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockPatchUserProfile extends Mock implements PatchUserProfile {}

class MockRequestEmailChange extends Mock implements RequestEmailChange {}

class MockPersonalDataCubit extends MockCubit<PersonalDataState>
    implements PersonalDataCubit {}

class MockSignInWithPassword extends Mock implements SignInWithPassword {}

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class MockSignUp extends Mock implements SignUp {}

class MockSignupCubit extends MockCubit<SignupState> implements SignupCubit {}

class MockVerifyEmailCode extends Mock implements VerifyEmailCode {}

class MockResendEmailVerificationCode extends Mock
    implements ResendEmailVerificationCode {}

class MockEmailCodeVerificationCubit
    extends MockCubit<EmailCodeVerificationState>
    implements EmailCodeVerificationCubit {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockCompleteGoogleSignup extends Mock implements CompleteGoogleSignup {}
