import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_invite_code_page.dart';

import '../../../auth/presentation/auth_test_harness.dart';

class MockAssistantInviteCubit extends MockCubit<AssistantInviteState>
    implements AssistantInviteCubit {}

void main() {
  late MockAssistantInviteCubit mockCubit;

  setUp(() {
    mockCubit = MockAssistantInviteCubit();
  });

  Widget createSubject() {
    return authTestApp(
      BlocProvider<AssistantInviteCubit>.value(
        value: mockCubit,
        child: const AssistantInviteCodePage(),
      ),
    );
  }

  testWidgets('renders invite title, subtitle, and input field', (tester) async {
    when(() => mockCubit.state).thenReturn(const AssistantInviteState());

    await tester.pumpWidget(createSubject());

    expect(find.text('Convite de assistente'), findsOneWidget);
    expect(
      find.text('Digite o código que o motorista compartilhou com você.'),
      findsOneWidget,
    );
    expect(find.text('Código do convite'), findsOneWidget);
    expect(find.text('Validar código'), findsOneWidget);
  });

  testWidgets('submit button is disabled when code is empty', (tester) async {
    when(() => mockCubit.state).thenReturn(const AssistantInviteState(code: ''));

    await tester.pumpWidget(createSubject());

    final button = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('submit button is enabled and calls validateCode when tapped',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const AssistantInviteState(code: 'ABC123'),
    );
    when(() => mockCubit.validateCode(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createSubject());

    final button = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byType(VanepPrimaryButton));
    await tester.pump();

    verify(() => mockCubit.validateCode(any())).called(1);
  });

  testWidgets('displays error text when code validation fails', (tester) async {
    when(() => mockCubit.state).thenReturn(
      const AssistantInviteState(
        code: 'BADCOD',
        codeFailure: AssistantFailure.invalidInviteCode,
      ),
    );

    await tester.pumpWidget(createSubject());

    expect(
      find.text(
        'Código de convite inválido. Verifique o código e tente novamente.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows loading state on submit button while validating',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const AssistantInviteState(
        code: 'ABC123',
        isValidatingCode: true,
      ),
    );

    await tester.pumpWidget(createSubject());

    final button = tester.widget<VanepPrimaryButton>(
      find.byType(VanepPrimaryButton),
    );
    expect(button.isLoading, isTrue);
  });
}
