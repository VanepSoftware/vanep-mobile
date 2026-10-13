import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockConversationRemoteDataSource extends Mock
    implements ConversationRemoteDataSource {}

class MockConversationRealtimeDataSource extends Mock
    implements ConversationRealtimeDataSource {}

class MockOpenConversation extends Mock implements OpenConversation {}

class MockListConversationMessages extends Mock
    implements ListConversationMessages {}

class MockSendConversationMessage extends Mock
    implements SendConversationMessage {}

class MockWatchConversation extends Mock implements WatchConversation {}

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}
