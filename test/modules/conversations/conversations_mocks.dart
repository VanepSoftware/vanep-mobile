import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockConversationRemoteDataSource extends Mock
    implements ConversationRemoteDataSource {}

class MockConversationRealtimeDataSource extends Mock
    implements ConversationRealtimeDataSource {}

class MockListConversationMessages extends Mock
    implements ListConversationMessages {}

class MockSendConversationMessage extends Mock
    implements SendConversationMessage {}

class MockWatchConversation extends Mock implements WatchConversation {}

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}

class MockListClientServiceRequests extends Mock
    implements ListClientServiceRequests {}

class MockListClientProposalVersions extends Mock
    implements ListClientProposalVersions {}

class MockFindConversationNegotiation extends Mock
    implements FindConversationNegotiation<ClientServiceRequest> {}

class MockNegotiationTimelineCubit
    extends MockCubit<NegotiationTimelineState<ClientServiceRequest>>
    implements NegotiationTimelineCubit<ClientServiceRequest> {}

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
