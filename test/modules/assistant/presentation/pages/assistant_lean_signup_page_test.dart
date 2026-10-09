import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_lean_signup_page.dart';

import '../../../auth/presentation/auth_test_harness.dart';

class MockAssistantInviteCubit extends MockCubit<AssistantInviteState>
    implements AssistantInviteCubit {}

void main() {
  late MockAssistantInviteCubit mockCubit;

  final testInvite = AssistantInvite(
    token: 'tok-999',
    driverName: 'Marcos Silva',
    vehicleDescription: 'Mercedes Sprinter',
    expiresAt: DateTime.utc(2026, 12, 31),
    status: 'PENDING',
  );

  setUp(() {
    mockCubit = MockAssistantInviteCubit();
  });

  Widget createSubject() {
    return authTestApp(
      BlocProvider<AssistantInviteCubit>.value(
        value: mockCubit,
        child: const AssistantLeanSignupPage(),
      ),
    );
  }

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('renders all lean registration fields and inviting driver card',
      (tester) async {
    useTallScreen(tester);
    when(() => mockCubit.state).thenReturn(
      AssistantInviteState(
        step: AssistantInviteStep.signup,
        invite: testInvite,
      ),
    );

    await tester.pumpWidget(createSubject());

    expect(find.text('Cadastro de assistente'), findsOneWidget);
    expect(find.text('Você foi convidado por Marcos Silva'), findsOneWidget);
    expect(find.text('Veículo: Mercedes Sprinter'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Data de nascimento'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Confirmar senha'), findsOneWidget);
    expect(find.text('Li e aceito os Termos de Uso'), findsOneWidget);
    expect(find.text('Concluir cadastro'), findsOneWidget);
  });

  testWidgets('triggers submitSignup when submit button is pressed',
      (tester) async {
    useTallScreen(tester);
    when(() => mockCubit.state).thenReturn(
      AssistantInviteState(
        step: AssistantInviteStep.signup,
        invite: testInvite,
        name: 'Carlos Silva',
        birthDate: DateTime(1995, 5, 20),
        email: 'carlos@vanep.com',
        cpf: '123.456.789-00',
        password: 'Password123!',
        passwordConfirmation: 'Password123!',
        acceptTerms: true,
      ),
    );
    when(() => mockCubit.submitSignup()).thenAnswer((_) async {});

    await tester.pumpWidget(createSubject());

    final submitButton = find.byType(VanepPrimaryButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    verify(() => mockCubit.submitSignup()).called(1);
  });

  testWidgets('displays field validation errors when present in state',
      (tester) async {
    useTallScreen(tester);
    when(() => mockCubit.state).thenReturn(
      const AssistantInviteState(
        step: AssistantInviteStep.signup,
        fieldErrors: {
          AssistantSignupField.name: AssistantSignupFieldError.required,
          AssistantSignupField.birthDate: AssistantSignupFieldError.underage,
          AssistantSignupField.email: AssistantSignupFieldError.invalid,
          AssistantSignupField.cpf: AssistantSignupFieldError.invalid,
          AssistantSignupField.password: AssistantSignupFieldError.required,
          AssistantSignupField.passwordConfirmation:
              AssistantSignupFieldError.mismatch,
          AssistantSignupField.acceptTerms:
              AssistantSignupFieldError.required,
        },
      ),
    );

    await tester.pumpWidget(createSubject());

    expect(find.text('Informe seu nome completo.'), findsOneWidget);
    expect(
      find.text('O assistente deve ter pelo menos 18 anos.'),
      findsOneWidget,
    );
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe um CPF válido.'), findsOneWidget);
    expect(find.text('Crie uma senha.'), findsOneWidget);
    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(
      find.text('Você deve aceitar os termos de uso para continuar.'),
      findsOneWidget,
    );
  });

  testWidgets('displays loading on submit button when isSubmittingSignup',
      (tester) async {
    useTallScreen(tester);
    when(() => mockCubit.state).thenReturn(
      const AssistantInviteState(
        step: AssistantInviteStep.signup,
        isSubmittingSignup: true,
      ),
    );

    await tester.pumpWidget(createSubject());

    final submitButton = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(submitButton.isLoading, isTrue);
  });
}
