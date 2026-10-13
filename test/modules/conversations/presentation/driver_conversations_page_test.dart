import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/driver_conversations_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/driver_conversations_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/driver_conversations_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

Widget harness(
  DriverConversationsCubit cubit,
  Future<void> Function(Conversation) onConversationTapped,
) {
  return localizedHarness(
    BlocProvider<DriverConversationsCubit>.value(
      value: cubit,
      child: DriverConversationsPage(
        onConversationTapped: onConversationTapped,
      ),
    ),
  );
}

void main() {
  late MockDriverConversationsCubit cubit;

  setUp(() {
    cubit = MockDriverConversationsCubit();
    when(() => cubit.loadConversations()).thenAnswer((_) async {});
  });

  void seed(DriverConversationsState state) {
    whenListen(
      cubit,
      const Stream<DriverConversationsState>.empty(),
      initialState: state,
    );
  }

  testWidgets('lists who wrote and reopens the chat on tap', (tester) async {
    seed(
      const DriverConversationsState(
        status: DriverConversationsStatus.ready,
        conversations: [testConversation],
      ),
    );
    final opened = <Conversation>[];

    await tester.pumpWidget(
      harness(cubit, (conversation) async => opened.add(conversation)),
    );
    await tester.tap(find.text('Ana Cliente'));
    await tester.pump();

    expect(find.text('Mensagens'), findsOneWidget);
    expect(opened, [testConversation]);
    verify(() => cubit.loadConversations()).called(1);
  });

  testWidgets('no conversations says where they will appear', (tester) async {
    seed(
      const DriverConversationsState(status: DriverConversationsStatus.ready),
    );

    await tester.pumpWidget(harness(cubit, (_) async {}));

    expect(
      find.text(
        'Nenhuma conversa ainda. Quando um cliente escrever, ela aparece aqui.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a failure is explained and can be retried', (tester) async {
    seed(
      const DriverConversationsState(
        status: DriverConversationsStatus.loadFailed,
        failure: ConversationNetworkFailure(),
      ),
    );

    await tester.pumpWidget(harness(cubit, (_) async {}));
    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Sem conexão com o servidor. Tente novamente.'),
      findsOneWidget,
    );
    verify(() => cubit.loadConversations()).called(1);
  });
}
