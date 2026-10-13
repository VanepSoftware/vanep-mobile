import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/conversations/data/dtos/conversation_dto.dart';
import 'package:vanep_mobile/modules/conversations/data/dtos/conversation_message_dto.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

const conversationHistoryPageSize = 30;

class ConversationRemoteDataSource {
  ConversationRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<Conversation> openConversation(String driverToken) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.conversationsEndpoint,
      data: {'driverToken': driverToken},
    );
    return readConversation(response.data);
  }

  Future<List<Conversation>> listDriverConversations() async {
    final response = await dio.get<List<dynamic>>(
      environment.conversationsMeEndpoint,
    );
    return readConversations(response.data);
  }

  Future<ConversationMessagePage> listMessages({
    required String conversationToken,
    required int page,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.conversationMessagesEndpoint(conversationToken),
      queryParameters: {'page': page, 'size': conversationHistoryPageSize},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty conversation history payload.');
    }
    return readConversationMessagePage(data);
  }

  Future<ConversationMessage> sendMessage({
    required String conversationToken,
    required String body,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.conversationMessagesEndpoint(conversationToken),
      data: {'body': body},
    );
    return readConversationMessage(response.data);
  }
}
