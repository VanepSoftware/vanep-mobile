import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_negotiation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockConversationRemoteDataSource extends Mock
    implements ConversationRemoteDataSource {}

class MockConversationRealtimeDataSource extends Mock
    implements ConversationRealtimeDataSource {}

class MockConversationNegotiationRepository extends Mock
    implements ConversationNegotiationRepository {}

class MockConversationNegotiationDataSource extends Mock
    implements ConversationNegotiationDataSource {}

class MockFindConversationNegotiation extends Mock
    implements FindConversationNegotiation {}

class MockOpenConversation extends Mock implements OpenConversation {}

class MockListConversationMessages extends Mock
    implements ListConversationMessages {}

class MockSendConversationMessage extends Mock
    implements SendConversationMessage {}

class MockWatchConversation extends Mock implements WatchConversation {}

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}

class MockListMyConversations extends Mock implements ListMyConversations {}

class MockConversationsInboxCubit extends MockCubit<ConversationsInboxState>
    implements ConversationsInboxCubit {}

MockConversationsInboxCubit readyConversationsCubit([
  List<Conversation> conversations = const [],
]) {
  final cubit = MockConversationsInboxCubit();
  whenListen(
    cubit,
    const Stream<ConversationsInboxState>.empty(),
    initialState: ConversationsInboxState(
      status: ConversationsInboxStatus.ready,
      conversations: conversations,
    ),
  );
  when(() => cubit.loadConversations()).thenAnswer((_) async {});
  return cubit;
}
