import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/access_token_source.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_driver_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';

void registerConversationsDependencies(GetIt getIt) {
  final environment = getIt<Environment>();

  getIt
    ..registerSingleton<ConversationRemoteDataSource>(
      ConversationRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: environment,
      ),
    )
    ..registerSingleton<ConversationRealtimeDataSource>(
      ConversationRealtimeDataSource(
        webSocketUrl: environment.conversationsWebSocketUrl,
        accessTokens: getIt<AccessTokenSource>(),
      ),
    )
    ..registerSingleton<ConversationRepository>(
      ConversationRepositoryImpl(
        remote: getIt<ConversationRemoteDataSource>(),
        realtime: getIt<ConversationRealtimeDataSource>(),
      ),
    )
    ..registerFactory<OpenConversation>(
      () => OpenConversation(getIt<ConversationRepository>()),
    )
    ..registerFactory<ListDriverConversations>(
      () => ListDriverConversations(getIt<ConversationRepository>()),
    )
    ..registerFactory<ListConversationMessages>(
      () => ListConversationMessages(getIt<ConversationRepository>()),
    )
    ..registerFactory<SendConversationMessage>(
      () => SendConversationMessage(getIt<ConversationRepository>()),
    )
    ..registerFactory<WatchConversation>(
      () => WatchConversation(getIt<ConversationRepository>()),
    );
}
