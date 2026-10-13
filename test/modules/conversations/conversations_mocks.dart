import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockConversationRemoteDataSource extends Mock
    implements ConversationRemoteDataSource {}

class MockConversationRealtimeDataSource extends Mock
    implements ConversationRealtimeDataSource {}
