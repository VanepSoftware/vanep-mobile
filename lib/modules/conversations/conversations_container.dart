import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/access_token_source.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_scenario.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/empty_conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/scenario_conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_negotiation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';

// TODO(VAN-44): switches between no negotiation and mocked negotiation via
// CONVERSATION_NEGOTIATION_SCENARIO; register the remote data source here once
// api-java #30 / #42 serve the negotiation and drop the scenario branch.
ConversationNegotiationDataSource conversationNegotiationDataSourceFor(
  String scenarioName,
) {
  final scenario = ConversationNegotiationScenario.fromName(scenarioName);
  if (scenario == null) return const EmptyConversationNegotiationDataSource();
  return ScenarioConversationNegotiationDataSource(scenario: scenario);
}

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
    ..registerSingleton<ConversationNegotiationRepository>(
      ConversationNegotiationRepositoryImpl(
        dataSource: conversationNegotiationDataSourceFor(
          environment.conversationNegotiationScenario,
        ),
      ),
    )
    ..registerFactory<FindConversationNegotiation>(
      () => FindConversationNegotiation(
        getIt<ConversationNegotiationRepository>(),
      ),
    )
    ..registerFactory<OpenConversation>(
      () => OpenConversation(getIt<ConversationRepository>()),
    )
    ..registerFactory<ListMyConversations>(
      () => ListMyConversations(getIt<ConversationRepository>()),
    )
    ..registerFactory<ListConversationMessages>(
      () => ListConversationMessages(getIt<ConversationRepository>()),
    )
    ..registerFactory<SendConversationMessage>(
      () => SendConversationMessage(getIt<ConversationRepository>()),
    )
    ..registerFactory<WatchConversation>(
      () => WatchConversation(getIt<ConversationRepository>()),
    )
    ..registerFactoryParam<ChatCubit, String?, Conversation?>(
      (driverToken, conversation) => ChatCubit(
        openConversation: getIt<OpenConversation>(),
        listConversationMessages: getIt<ListConversationMessages>(),
        sendConversationMessage: getIt<SendConversationMessage>(),
        watchConversation: getIt<WatchConversation>(),
        findConversationNegotiation: getIt<FindConversationNegotiation>(),
        driverToken: driverToken,
        conversation: conversation,
      ),
    )
    ..registerFactory<ConversationsInboxCubit>(
      () => ConversationsInboxCubit(
        listMyConversations: getIt<ListMyConversations>(),
      ),
    );
}
