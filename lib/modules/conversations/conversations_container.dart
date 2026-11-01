import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/access_token_source.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';

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
    ..registerFactoryParam<ChatCubit, String, void>(
      (conversationToken, _) => ChatCubit(
        listConversationMessages: getIt<ListConversationMessages>(),
        sendConversationMessage: getIt<SendConversationMessage>(),
        watchConversation: getIt<WatchConversation>(),
        conversationToken: conversationToken,
      ),
    )
    ..registerFactory<FindConversationNegotiation<ClientServiceRequest>>(
      () => FindConversationNegotiation(
        listRequests: getIt<ListClientServiceRequests>().call,
        listVersions: getIt<ListClientProposalVersions>().call,
      ),
    )
    ..registerFactoryParam<
      NegotiationTimelineCubit<ClientServiceRequest>,
      String,
      void
    >(
      (conversationToken, _) => NegotiationTimelineCubit(
        conversationToken: conversationToken,
        findNegotiation:
            getIt<FindConversationNegotiation<ClientServiceRequest>>(),
      ),
    )
    ..registerFactory<ConversationsInboxCubit>(
      () => ConversationsInboxCubit(
        listMyConversations: getIt<ListMyConversations>(),
      ),
    );
}
