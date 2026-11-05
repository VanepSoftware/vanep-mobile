import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_state.dart';

import '../../mocks/assistant_mocks.dart';

void main() {
  late MockValidateAssistantInvite mockValidateInvite;
  late MockRegisterAssistantWithInvite mockRegisterWithInvite;

  final testInvite = AssistantInvite(
    token: 'tok-123',
    driverName: 'Marcos Silva',
    vehicleDescription: 'Mercedes Sprinter',
    expiresAt: DateTime.utc(2026, 12, 31),
    status: 'PENDING',
  );

  setUp(() {
    mockValidateInvite = MockValidateAssistantInvite();
    mockRegisterWithInvite = MockRegisterAssistantWithInvite();
  });

  group('AssistantInviteCubit', () {
    test('initial state has step=code and empty fields', () {
      final cubit = AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      );

      expect(cubit.state.step, AssistantInviteStep.code);
      expect(cubit.state.code, '');
      expect(cubit.state.isValidatingCode, isFalse);
      expect(cubit.state.invite, isNull);
      expect(cubit.state.codeFailure, isNull);
    });

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'automatically validates code if initialCode is provided',
      setUp: () {
        when(() => mockValidateInvite('ABC123'))
            .thenAnswer((_) async => Ok(testInvite));
      },
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
        initialCode: 'ABC123',
      ),
      expect: () => [
        AssistantInviteState(
          code: 'ABC123',
          isValidatingCode: false,
          invite: testInvite,
          step: AssistantInviteStep.signup,
        ),
      ],
      verify: (_) {
        verify(() => mockValidateInvite('ABC123')).called(1);
      },
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'updateCode emits updated code and clears failure',
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      seed: () => const AssistantInviteState(
        codeFailure: AssistantFailure.invalidInviteCode,
      ),
      act: (cubit) => cubit.updateCode('XYZ789'),
      expect: () => [
        const AssistantInviteState(code: 'XYZ789', codeFailure: null),
      ],
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'validateCode emits signup step on success',
      setUp: () {
        when(() => mockValidateInvite('CODE12'))
            .thenAnswer((_) async => Ok(testInvite));
      },
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      act: (cubit) {
        cubit.updateCode('CODE12');
        return cubit.validateCode();
      },
      expect: () => [
        const AssistantInviteState(code: 'CODE12'),
        const AssistantInviteState(
          code: 'CODE12',
          isValidatingCode: true,
        ),
        AssistantInviteState(
          code: 'CODE12',
          isValidatingCode: false,
          invite: testInvite,
          step: AssistantInviteStep.signup,
        ),
      ],
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'validateCode emits codeFailure on failure',
      setUp: () {
        when(() => mockValidateInvite('BADCOD'))
            .thenAnswer((_) async => const Err(AssistantFailure.invalidInviteCode));
      },
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      act: (cubit) {
        cubit.updateCode('BADCOD');
        return cubit.validateCode();
      },
      expect: () => [
        const AssistantInviteState(code: 'BADCOD'),
        const AssistantInviteState(
          code: 'BADCOD',
          isValidatingCode: true,
        ),
        const AssistantInviteState(
          code: 'BADCOD',
          isValidatingCode: false,
          codeFailure: AssistantFailure.invalidInviteCode,
        ),
      ],
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'field updates emit modified state',
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      act: (cubit) {
        cubit.updateName('Ana Costa');
        cubit.updateEmail('ana@vanep.com');
        cubit.updateCpf('123.456.789-00');
        cubit.updatePassword('Password123!');
        cubit.updatePasswordConfirmation('Password123!');
        cubit.updateAcceptTerms(true);
      },
      expect: () => [
        const AssistantInviteState(name: 'Ana Costa'),
        const AssistantInviteState(name: 'Ana Costa', email: 'ana@vanep.com'),
        const AssistantInviteState(
          name: 'Ana Costa',
          email: 'ana@vanep.com',
          cpf: '123.456.789-00',
        ),
        const AssistantInviteState(
          name: 'Ana Costa',
          email: 'ana@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
        ),
        const AssistantInviteState(
          name: 'Ana Costa',
          email: 'ana@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
        ),
        const AssistantInviteState(
          name: 'Ana Costa',
          email: 'ana@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
          acceptTerms: true,
        ),
      ],
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'submitSignup emits fieldErrors when validation fails',
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      seed: () => const AssistantInviteState(
        step: AssistantInviteStep.signup,
        name: '',
        email: 'invalid-email',
        cpf: '123',
        password: 'weak',
        passwordConfirmation: 'diff',
        acceptTerms: false,
      ),
      act: (cubit) => cubit.submitSignup(),
      expect: () => [
        const AssistantInviteState(
          step: AssistantInviteStep.signup,
          name: '',
          email: 'invalid-email',
          cpf: '123',
          password: 'weak',
          passwordConfirmation: 'diff',
          acceptTerms: false,
          fieldErrors: {
            AssistantSignupField.name: AssistantSignupFieldError.required,
            AssistantSignupField.birthDate: AssistantSignupFieldError.required,
            AssistantSignupField.email: AssistantSignupFieldError.invalid,
            AssistantSignupField.cpf: AssistantSignupFieldError.invalid,
            AssistantSignupField.password: AssistantSignupFieldError.invalid,
            AssistantSignupField.passwordConfirmation:
                AssistantSignupFieldError.mismatch,
            AssistantSignupField.acceptTerms:
                AssistantSignupFieldError.required,
          },
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockRegisterWithInvite(
            inviteToken: any(named: 'inviteToken'),
            name: any(named: 'name'),
            birthDate: any(named: 'birthDate'),
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            password: any(named: 'password'),
            acceptTerms: any(named: 'acceptTerms'),
          ),
        );
      },
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'submitSignup succeeds when all fields are valid',
      setUp: () {
        when(
          () => mockRegisterWithInvite(
            inviteToken: any(named: 'inviteToken'),
            name: any(named: 'name'),
            birthDate: any(named: 'birthDate'),
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            password: any(named: 'password'),
            acceptTerms: any(named: 'acceptTerms'),
          ),
        ).thenAnswer((_) async => const Ok(null));
      },
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      seed: () => AssistantInviteState(
        step: AssistantInviteStep.signup,
        invite: testInvite,
        code: 'ABC123',
        name: 'Carlos Silva',
        birthDate: DateTime(1995, 5, 20),
        email: 'carlos@vanep.com',
        cpf: '123.456.789-00',
        password: 'Password123!',
        passwordConfirmation: 'Password123!',
        acceptTerms: true,
      ),
      act: (cubit) => cubit.submitSignup(),
      expect: () => [
        AssistantInviteState(
          step: AssistantInviteStep.signup,
          invite: testInvite,
          code: 'ABC123',
          name: 'Carlos Silva',
          birthDate: DateTime(1995, 5, 20),
          email: 'carlos@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
          acceptTerms: true,
          isSubmittingSignup: true,
        ),
        AssistantInviteState(
          step: AssistantInviteStep.success,
          invite: testInvite,
          code: 'ABC123',
          name: 'Carlos Silva',
          birthDate: DateTime(1995, 5, 20),
          email: 'carlos@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
          acceptTerms: true,
          isSubmittingSignup: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRegisterWithInvite(
            inviteToken: 'tok-123',
            name: 'Carlos Silva',
            birthDate: '1995-05-20',
            email: 'carlos@vanep.com',
            cpf: '123.456.789-00',
            password: 'Password123!',
            acceptTerms: true,
          ),
        ).called(1);
      },
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'submitSignup emits signupFailure on registration error',
      setUp: () {
        when(
          () => mockRegisterWithInvite(
            inviteToken: any(named: 'inviteToken'),
            name: any(named: 'name'),
            birthDate: any(named: 'birthDate'),
            email: any(named: 'email'),
            cpf: any(named: 'cpf'),
            password: any(named: 'password'),
            acceptTerms: any(named: 'acceptTerms'),
          ),
        ).thenAnswer((_) async => const Err(AssistantFailure.network));
      },
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      seed: () => AssistantInviteState(
        step: AssistantInviteStep.signup,
        invite: testInvite,
        code: 'ABC123',
        name: 'Carlos Silva',
        birthDate: DateTime(1995, 5, 20),
        email: 'carlos@vanep.com',
        cpf: '123.456.789-00',
        password: 'Password123!',
        passwordConfirmation: 'Password123!',
        acceptTerms: true,
      ),
      act: (cubit) => cubit.submitSignup(),
      expect: () => [
        AssistantInviteState(
          step: AssistantInviteStep.signup,
          invite: testInvite,
          code: 'ABC123',
          name: 'Carlos Silva',
          birthDate: DateTime(1995, 5, 20),
          email: 'carlos@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
          acceptTerms: true,
          isSubmittingSignup: true,
        ),
        AssistantInviteState(
          step: AssistantInviteStep.signup,
          invite: testInvite,
          code: 'ABC123',
          name: 'Carlos Silva',
          birthDate: DateTime(1995, 5, 20),
          email: 'carlos@vanep.com',
          cpf: '123.456.789-00',
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
          acceptTerms: true,
          isSubmittingSignup: false,
          signupFailure: AssistantFailure.network,
        ),
      ],
    );

    blocTest<AssistantInviteCubit, AssistantInviteState>(
      'goToCodeStep switches step back to code',
      build: () => AssistantInviteCubit(
        validateInvite: mockValidateInvite,
        registerWithInvite: mockRegisterWithInvite,
      ),
      seed: () => const AssistantInviteState(step: AssistantInviteStep.signup),
      act: (cubit) => cubit.goToCodeStep(),
      expect: () => [
        const AssistantInviteState(step: AssistantInviteStep.code),
      ],
    );
  });
}
